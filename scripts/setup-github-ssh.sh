#!/usr/bin/env bash
# Setup SSH key for GitHub
# Generates a new SSH key if one doesn't exist and provides instructions for adding it to GitHub
set -euo pipefail

SSH_DIR="$HOME/.ssh"
SSH_KEY_FILE="$SSH_DIR/id_ed25519"
SSH_CONFIG="$SSH_DIR/config"
GITHUB_HOST="github.com"
GITHUB_EMAIL="${GITHUB_EMAIL:-${1:-}}"

echo "Setting up SSH key for GitHub..."
echo ""

# Create .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating .ssh directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Check if SSH key already exists
if [ -f "$SSH_KEY_FILE" ]; then
    echo "✓ SSH key already exists: $SSH_KEY_FILE"
    echo "  Skipping key generation"
    USING_EXISTING=true
else
    USING_EXISTING=false
fi

# Generate new SSH key if needed
if [ "$USING_EXISTING" = false ]; then
    echo "Generating new SSH key..."
    
    # Use provided email or prompt for it
    if [ -z "$GITHUB_EMAIL" ]; then
        read -p "Enter your GitHub email address: " GITHUB_EMAIL
    fi
    
    if [ -z "$GITHUB_EMAIL" ]; then
        echo "✗ Email cannot be empty"
        exit 1
    fi
    
    # Backup existing key if present
    if [ -f "$SSH_KEY_FILE" ]; then
        BACKUP_FILE="${SSH_KEY_FILE}.backup.$(date +%s)"
        echo "  Backing up existing key to $BACKUP_FILE"
        mv "$SSH_KEY_FILE" "$BACKUP_FILE"
        if [ -f "${SSH_KEY_FILE}.pub" ]; then
            mv "${SSH_KEY_FILE}.pub" "${BACKUP_FILE}.pub"
        fi
    fi
    
    # Generate Ed25519 key (modern, secure, shorter than RSA)
    echo "  Generating Ed25519 key for $GITHUB_EMAIL..."
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$SSH_KEY_FILE" -N ""
    
    echo "✓ SSH key generated successfully"
else
    echo "Using existing SSH key"
fi

echo ""
echo "Step 1: SSH Key Setup"
echo "===================="
echo ""

if [ "$USING_EXISTING" = false ]; then
    echo "SSH public key:"
    echo ""
    PUBLIC_KEY=$(cat "${SSH_KEY_FILE}.pub")
    echo "$PUBLIC_KEY"
    echo ""
    echo "To add this key to GitHub:"
    echo "1. Go to https://github.com/settings/keys"
    echo "2. Click 'New SSH key'"
    echo "3. Paste the key shown above"
    echo "4. Give it a title (e.g., 'My Dev Machine')"
    echo "5. Click 'Add SSH key'"
    echo ""
else
    PUBLIC_KEY=$(cat "${SSH_KEY_FILE}.pub")
    echo "Using existing SSH key:"
    echo "$PUBLIC_KEY"
    echo ""
fi

# Start SSH agent if not already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "Step 2: Starting SSH agent"
    echo "=========================="
    eval "$(ssh-agent -s)"
else
    echo "Step 2: SSH agent already running"
    echo "================================="
fi

echo "Adding key to SSH agent..."
ssh-add "$SSH_KEY_FILE" 2>/dev/null || true
echo ""

# Configure SSH config for GitHub if not already configured
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    echo "Step 3: Configuring SSH config"
    echo "=============================="
    
    if [ ! -f "$SSH_CONFIG" ]; then
        touch "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
    fi
    
    cat >> "$SSH_CONFIG" <<EOF

# GitHub SSH configuration
Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY_FILE
    AddKeysToAgent yes
    IdentitiesOnly yes
EOF
    
    echo "✓ SSH config updated"
else
    echo "Step 3: SSH config already configured"
    echo "====================================="
fi

echo ""
echo "✓ GitHub SSH setup complete!"
echo ""
echo "Key location: $SSH_KEY_FILE"
echo "Public key location: ${SSH_KEY_FILE}.pub"
echo "SSH config location: $SSH_CONFIG"
echo ""

if [ "$USING_EXISTING" = false ]; then
    echo "NEXT STEPS:"
    echo "=========="
    echo "1. Add your SSH key to GitHub:"
    echo "   https://github.com/settings/keys"
    echo ""
    echo "2. Test the connection:"
    echo "   ssh -T git@github.com"
    echo ""
    echo "3. You can now clone and push to GitHub via SSH:"
    echo "   git clone git@github.com:user/repo.git"
else
    echo "Your existing SSH key is ready to use!"
fi

