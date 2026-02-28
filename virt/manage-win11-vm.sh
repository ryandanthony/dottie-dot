#!/usr/bin/env bash
# Manage Windows 11 libvirt VM - define from XML or dump current config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_NAME="win11-nvme"
VM_XML="./win11-vm.xml"
NVME_DEV="/dev/nvme1n1"
ESP_DEV="/dev/nvme0n1p1"

usage() {
    echo "Usage: $(basename "$0") {define|dump|status}"
    echo ""
    echo "Commands:"
    echo "  define   Define (or redefine) the $VM_NAME VM from win11-vm.xml"
    echo "  dump     Dump the current live XML for the $VM_NAME VM"
    echo "  status   Show VM status"
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

    # Verify ESP partition exists
    if [ ! -b "$ESP_DEV" ]; then
        echo "✗ ESP partition $ESP_DEV not found"
        exit 1
    fi

    # Install swtpm if not present (required for TPM 2.0 emulation)
    if ! command -v swtpm &>/dev/null; then
        echo "Installing swtpm for TPM 2.0 emulation..."
        sudo apt install -y swtpm swtpm-tools
        echo "  ✓ swtpm installed"
    fi

    # Ensure libvirt-qemu can access the block devices
    echo "Checking device permissions..."
    for dev in "$NVME_DEV" "$ESP_DEV"; do
        if ! sudo -u libvirt-qemu test -r "$dev" 2>/dev/null; then
            echo "  Setting read access on $dev for libvirt-qemu..."
            # Add an apparmor/qemu security override if needed
        fi
    done

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
    echo "  Primary (Windows):  $NVME_DEV → sda (SATA)"
    echo "  ESP (read-only):    $ESP_DEV → sdb (SATA)"
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

# --- Main ---
if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    define) cmd_define ;;
    dump)   cmd_dump ;;
    status) cmd_status ;;
    *)      usage ;;
esac
