#!/usr/bin/env bash
# Manage Windows 11 libvirt VM - define from XML or dump current config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_NAME="win11-nvme"
VM_XML="./win11-vm.xml"
NVME_DEV="/dev/nvme0n1"
ESP_IMG="/var/lib/libvirt/images/win11-esp.img"

usage() {
    echo "Usage: $(basename "$0") {define|dump|status|rebuild-esp}"
    echo ""
    echo "Commands:"
    echo "  define       Define (or redefine) the $VM_NAME VM from win11-vm.xml"
    echo "  dump         Dump the current live XML for the $VM_NAME VM"
    echo "  status       Show VM status"
    echo "  rebuild-esp  Rebuild the virtual ESP image from the host's EFI partition"
    exit 1
}

check_libvirt() {
    if ! command -v virsh &>/dev/null; then
        echo "✗ virsh not found. Install libvirt-clients first."
        exit 1
    fi
    if ! systemctl is-active --quiet libvirtd; then
        echo "✗ libvirtd is not running. Start it with: sudo systemctl start libvirtd"
        exit 1
    fi
}

cmd_define() {
    check_libvirt

    if [ ! -f "$VM_XML" ]; then
        echo "✗ VM XML not found at $VM_XML"
        exit 1
    fi

    # Verify NVMe device exists
    if [ ! -b "$NVME_DEV" ]; then
        echo "✗ NVMe device $NVME_DEV not found"
        exit 1
    fi

    # Verify virtual ESP image exists
    if [ ! -f "$ESP_IMG" ]; then
        echo "✗ Virtual ESP image $ESP_IMG not found"
        echo "  Create it with: $(basename "$0") rebuild-esp"
        exit 1
    fi

    # Install swtpm if not present (required for TPM 2.0 emulation)
    if ! command -v swtpm &>/dev/null; then
        echo "Installing swtpm for TPM 2.0 emulation..."
        sudo apt install -y swtpm swtpm-tools
        echo "  ✓ swtpm installed"
    fi

    # Ensure libvirt-qemu can access the block device and ESP image
    echo "Checking device permissions..."
    if ! sudo -u libvirt-qemu test -r "$NVME_DEV" 2>/dev/null; then
        echo "  Setting read access on $NVME_DEV for libvirt-qemu..."
        # Add an apparmor/qemu security override if needed
    fi
    sudo chown libvirt-qemu:kvm "$ESP_IMG" 2>/dev/null || true

    # Define or redefine the VM
    if virsh list --all --name | grep -qx "$VM_NAME"; then
        echo "Redefining $VM_NAME VM..."
        virsh define "$VM_XML"
    else
        echo "Defining $VM_NAME VM..."
        virsh define "$VM_XML"
    fi

    echo "  ✓ $VM_NAME VM defined"
    echo ""
    echo "Disk layout:"
    echo "  ESP (virtual):      $ESP_IMG → sda (SATA)"
    echo "  Primary (Windows):  $NVME_DEV → sdb (SATA)"
    echo ""
    echo "Next steps:"
    echo "  1. Place your Windows 11 ISO at /var/lib/libvirt/images/Win11.iso"
    echo "  2. Download VirtIO drivers ISO from:"
    echo "     https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
    echo "     and place at /var/lib/libvirt/images/virtio-win.iso"
    echo "  3. Start the VM:  virsh start $VM_NAME"
    echo "  4. Open viewer:   virt-manager (or virt-viewer $VM_NAME)"
    echo ""
    echo "  After Windows boots, install VirtIO drivers from the ISO,"
    echo "  then edit the XML to switch the primary disk to bus='virtio' for better performance."
}

cmd_dump() {
    check_libvirt

    if ! virsh list --all --name | grep -qx "$VM_NAME"; then
        echo "✗ VM '$VM_NAME' is not defined. Run '$(basename "$0") define' first."
        exit 1
    fi

    virsh dumpxml "$VM_NAME"
}

cmd_status() {
    check_libvirt

    if ! virsh list --all --name | grep -qx "$VM_NAME"; then
        echo "VM '$VM_NAME' is not defined."
        exit 1
    fi

    echo "VM: $VM_NAME"
    virsh domstate "$VM_NAME"
    echo ""
    virsh dominfo "$VM_NAME"
}

cmd_rebuild_esp() {
    local HOST_ESP="/boot/efi"
    local TMP_IMG="/tmp/win11-esp.img"
    local TMP_MNT="/tmp/virt-esp-mnt"

    # Verify host ESP is mounted
    if ! mountpoint -q "$HOST_ESP"; then
        echo "✗ Host ESP not mounted at $HOST_ESP"
        exit 1
    fi

    if [ ! -f "$HOST_ESP/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
        echo "✗ Windows Boot Manager not found at $HOST_ESP/EFI/Microsoft/Boot/bootmgfw.efi"
        exit 1
    fi

    echo "Building virtual ESP image..."

    # Create 256M raw image with GPT + EFI System Partition
    truncate -s 256M "$TMP_IMG"
    sgdisk --clear \
           --new=1:2048:+250M \
           --typecode=1:EF00 \
           --change-name=1:"EFI System" \
           "$TMP_IMG" >/dev/null

    # Attach, format, and populate
    LOOP=$(sudo losetup --find --show --partscan "$TMP_IMG")
    trap 'sudo umount "$TMP_MNT" 2>/dev/null; sudo losetup -d "$LOOP" 2>/dev/null; rm -f "$TMP_IMG"' EXIT

    sudo mkfs.fat -F 32 -n "ESP" "${LOOP}p1" >/dev/null
    sudo mkdir -p "$TMP_MNT"
    sudo mount "${LOOP}p1" "$TMP_MNT"

    sudo mkdir -p "$TMP_MNT/EFI/BOOT" "$TMP_MNT/EFI/Microsoft"
    sudo cp -a "$HOST_ESP/EFI/Microsoft/"* "$TMP_MNT/EFI/Microsoft/"
    sudo cp "$HOST_ESP/EFI/BOOT/BOOTX64.EFI" "$TMP_MNT/EFI/BOOT/"

    sudo umount "$TMP_MNT"
    sudo losetup -d "$LOOP"
    trap - EXIT

    # Move into place
    sudo mv "$TMP_IMG" "$ESP_IMG"
    sudo chown libvirt-qemu:kvm "$ESP_IMG"

    echo "  ✓ Virtual ESP image created at $ESP_IMG"
    echo "    Contains: EFI/BOOT/BOOTX64.EFI, EFI/Microsoft/Boot/*"
}

# --- Main ---
if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    define)      cmd_define ;;
    dump)        cmd_dump ;;
    status)      cmd_status ;;
    rebuild-esp) cmd_rebuild_esp ;;
    *)           usage ;;
esac
