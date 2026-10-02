#!/usr/bin/env bash
# Allow the current user to use /dev/uinput without root.
# Needed by ydotool (keystroke injection used by ghostlay). KWin does not
# expose the Wayland virtual-keyboard protocol to normal clients, so wtype
# fails on KDE ("Compositor does not support the virtual keyboard
# protocol"); ydotool goes through the kernel uinput device instead.
set -euo pipefail

echo "Setting up uinput access for ydotool..."

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
RULE_FILE="/etc/udev/rules.d/60-uinput.rules"
RULE='KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"'
MODULES_FILE="/etc/modules-load.d/uinput.conf"

# Load uinput at boot and now
if [[ ! -f "$MODULES_FILE" ]] || ! grep -qx "uinput" "$MODULES_FILE"; then
    echo "uinput" | $SUDO tee "$MODULES_FILE" >/dev/null
    echo "✓ uinput added to $MODULES_FILE"
fi
$SUDO modprobe uinput 2>/dev/null || true

# udev rule: group 'input' gets rw on /dev/uinput
if [[ ! -f "$RULE_FILE" ]] || ! grep -qxF "$RULE" "$RULE_FILE"; then
    echo "$RULE" | $SUDO tee "$RULE_FILE" >/dev/null
    $SUDO udevadm control --reload-rules
    $SUDO udevadm trigger --name-match=uinput 2>/dev/null || true
    echo "✓ udev rule written to $RULE_FILE"
else
    echo "✓ udev rule already present"
fi

# Put the user in the 'input' group
if id -nG "$CURRENT_USER" | tr ' ' '\n' | grep -qx input; then
    echo "✓ $CURRENT_USER already in group 'input'"
else
    $SUDO usermod -aG input "$CURRENT_USER"
    echo "✓ Added $CURRENT_USER to group 'input' (log out/in to take effect)"
fi
