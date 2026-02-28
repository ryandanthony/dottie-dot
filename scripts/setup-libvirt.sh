#!/usr/bin/env bash
# Setup libvirt/KVM permissions and default network
# Ensures the current user can manage VMs without sudo
set -euo pipefail

echo "Setting up libvirt/KVM permissions..."

# Check if libvirt is installed
if ! command -v virsh &>/dev/null; then
    echo "⚠ virsh not found. Skipping libvirt setup."
    echo "  It will be configured after libvirt-clients is installed."
    exit 0
fi

# Check if running as root or have sudo access
if [[ $EUID -ne 0 ]]; then
    if ! sudo -n true 2>/dev/null; then
        echo "✗ This script requires sudo privileges"
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

CURRENT_USER="${SUDO_USER:-$USER}"

# Step 1: Add user to libvirt and kvm groups
echo "Step 1: Configuring user permissions..."
for group in libvirt kvm; do
    if getent group "$group" > /dev/null 2>&1; then
        if ! id -nG "$CURRENT_USER" | grep -qw "$group"; then
            echo "  Adding $CURRENT_USER to $group group..."
            $SUDO usermod -aG "$group" "$CURRENT_USER"
            echo "  ✓ User added to $group group"
        else
            echo "  ✓ $CURRENT_USER already in $group group"
        fi
    else
        echo "  ⚠ Group $group does not exist, skipping"
    fi
done

# Step 2: Ensure the default network is defined and active
echo ""
echo "Step 2: Configuring default network..."
if $SUDO virsh net-list --all --name 2>/dev/null | grep -qx "default"; then
    NET_INFO=$($SUDO virsh net-info default 2>/dev/null || true)
    if ! echo "$NET_INFO" | grep -qE "^Active:\s+yes"; then
        echo "  Starting default network..."
        $SUDO virsh net-start default
        echo "  ✓ Default network started"
    else
        echo "  ✓ Default network already active"
    fi

    if ! echo "$NET_INFO" | grep -qE "^Autostart:\s+yes"; then
        echo "  Enabling default network autostart..."
        $SUDO virsh net-autostart default
        echo "  ✓ Default network set to autostart"
    else
        echo "  ✓ Default network autostart already enabled"
    fi
else
    echo "  Defining default network..."
    $SUDO virsh net-define /usr/share/libvirt/networks/default.xml 2>/dev/null || true
    $SUDO virsh net-start default
    $SUDO virsh net-autostart default
    echo "  ✓ Default network defined, started, and set to autostart"
fi

# Step 3: Ensure libvirtd is enabled and running
echo ""
echo "Step 3: Ensuring libvirtd service is active..."
if ! systemctl is-enabled --quiet libvirtd 2>/dev/null; then
    $SUDO systemctl enable libvirtd
    echo "  ✓ libvirtd enabled"
else
    echo "  ✓ libvirtd already enabled"
fi

if ! systemctl is-active --quiet libvirtd 2>/dev/null; then
    $SUDO systemctl start libvirtd
    echo "  ✓ libvirtd started"
else
    echo "  ✓ libvirtd already running"
fi

echo ""
echo "✓ Libvirt setup complete"
if ! id -nG "$CURRENT_USER" | grep -qw "libvirt"; then
    echo "  ⚠ Log out and back in for group changes to take effect"
fi
