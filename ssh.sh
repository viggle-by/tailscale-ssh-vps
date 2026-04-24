#!/bin/bash
set -e

USERNAME="mysticgiggle"
PASSWORD="giggle"

echo "Updating system..."
sudo apt-get update -y
sudo apt-get install -y curl

# -------------------------
# Create user
# -------------------------
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
else
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    echo "User $USERNAME created"
fi

sudo usermod -aG sudo "$USERNAME"
echo "User added to sudo group"

# -------------------------
# Install Tailscale
# -------------------------
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

sudo systemctl enable tailscaled
sudo systemctl start tailscaled

# -------------------------
# Enable Tailscale SSH
# -------------------------
echo "Starting Tailscale with SSH enabled..."

if [ -n "$TS_AUTHKEY" ]; then
    sudo tailscale up \
        --authkey="$TS_AUTHKEY" \
        --ssh
    echo "Tailscale is up with SSH enabled"
else
    echo "ERROR: TS_AUTHKEY is required for non-interactive setup"
    exit 1
fi

echo "Done."
