#!/usr/bin/env bash
# Setup Docker security and permissions
# Fixes permission denied errors and implements security best practices
set -euo pipefail

DOCKER_CONFIG_DIR="/etc/docker"
DOCKER_DAEMON_CONFIG="$DOCKER_CONFIG_DIR/daemon.json"

echo "Setting up Docker security and permissions..."

# Check if Docker is installed
if ! command -v docker &>/dev/null; then
    echo "⚠ Docker is not installed yet. Skipping security setup."
    echo "  It will be configured after Docker is installed."
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

# Step 1: Add current user to docker group
echo "Step 1: Configuring user permissions..."
CURRENT_USER="${SUDO_USER:-$USER}"

if getent group docker > /dev/null; then
    if ! id "$CURRENT_USER" | grep -q docker; then
        echo "  Adding $CURRENT_USER to docker group..."
        $SUDO usermod -aG docker "$CURRENT_USER"
        echo "  ✓ User added to docker group"
    else
        echo "  ✓ $CURRENT_USER already in docker group"
    fi
else
    echo "  Creating docker group..."
    $SUDO groupadd docker
    $SUDO usermod -aG docker "$CURRENT_USER"
    echo "  ✓ docker group created and user added"
fi

# Step 2: Set proper socket permissions
echo ""
echo "Step 2: Configuring Docker socket permissions..."
if [ -S /var/run/docker.sock ]; then
    echo "  Setting docker socket permissions..."
    $SUDO chmod 660 /var/run/docker.sock
    $SUDO chgrp docker /var/run/docker.sock
    echo "  ✓ Socket permissions updated"
fi

# Step 3: Create secure daemon.json configuration
echo ""
echo "Step 3: Applying security configuration..."

# Backup existing daemon.json if it exists
if [ -f "$DOCKER_DAEMON_CONFIG" ]; then
    echo "  Backing up existing daemon.json..."
    $SUDO cp "$DOCKER_DAEMON_CONFIG" "$DOCKER_DAEMON_CONFIG.backup.$(date +%s)"
fi

# Create secure daemon.json configuration
echo "  Creating secure daemon configuration..."
$SUDO tee "$DOCKER_DAEMON_CONFIG" > /dev/null <<'EOF'
{
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "userland-proxy": false,
  "no-new-privileges": true
}
EOF

# Step 4: Set proper permissions on config files
echo "  Setting proper permissions on config files..."
$SUDO chmod 600 "$DOCKER_DAEMON_CONFIG"
$SUDO chmod 755 "$DOCKER_CONFIG_DIR"

# Step 5: Reload Docker daemon with error handling
echo ""
echo "Step 4: Restarting Docker daemon..."
$SUDO systemctl daemon-reload

# Try to restart Docker and capture output
if ! $SUDO systemctl restart docker 2>&1; then
    echo "  ✗ Docker failed to restart. Checking configuration..."
    echo "  Restoring from backup..."
    if [ -f "$DOCKER_DAEMON_CONFIG.backup"* ]; then
        LATEST_BACKUP=$(ls -t "$DOCKER_DAEMON_CONFIG.backup"* 2>/dev/null | head -1)
        $SUDO cp "$LATEST_BACKUP" "$DOCKER_DAEMON_CONFIG"
        $SUDO systemctl restart docker
        echo "  ✓ Restored from backup and Docker restarted"
        echo "  ⚠ Some security settings may not have been applied"
    fi
fi

# Step 6: Verify setup
echo ""
echo "Step 5: Verifying configuration..."
sleep 2

if [ -S /var/run/docker.sock ]; then
    SOCKET_PERMS=$(ls -l /var/run/docker.sock | awk '{print $1}')
    SOCKET_GROUP=$(ls -l /var/run/docker.sock | awk '{print $4}')
    echo "  ✓ Docker socket is responsive"
    echo "    Permissions: $SOCKET_PERMS"
    echo "    Group: $SOCKET_GROUP"
fi

echo ""
echo "✓ Docker security setup complete!"
echo ""
echo "Security settings applied:"
echo "  • User added to docker group"
echo "  • Docker socket permissions configured (660)"
echo "  • Live restore enabled for container recovery"
echo "  • JSON-file logging with rotation (10m max, 3 files)"
echo "  • Userland proxy disabled"
echo "  • No new privileges flag enabled"
echo ""
echo "IMPORTANT: You may need to log out and log back in for group changes to take effect."
echo "Or run: newgrp docker"
echo ""
echo "To test permissions, run:"
echo "  docker ps"
echo ""
