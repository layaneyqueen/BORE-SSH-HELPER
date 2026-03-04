#!/bin/bash

echo "Starting free SSH IP..."

# Ensure root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root or using sudo!"
    exit 1
fi

# Install dependencies if Bore is missing
if ! command -v bore &>/dev/null; then
    echo "Installing Bore dependencies..."
    apt update
    apt install -y build-essential pkg-config libssl-dev curl screen
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    rustup install nightly
    rustup default nightly
    cargo install bore-cli
fi

SCREEN_NAME="bore_ssh_tunnel"
TMP_LOG="/tmp/bore-port.log"

# Kill old screen if exists
screen -S "$SCREEN_NAME" -X quit 2>/dev/null

# Start Bore in a detached screen
screen -dmS "$SCREEN_NAME" bash -c "bore local 22 --to bore.pub"

# Wait and check for Bore output
PORT=""
for i in {1..20}; do
    sleep 2
    # Grab the latest output from screen into /tmp/bore-port.log
    screen -S "$SCREEN_NAME" -X hardcopy "$TMP_LOG"
    # Look for 'listening at bore.pub:' and extract port
    PORT=$(grep -oP 'listening at bore\.pub:\K[0-9]+' "$TMP_LOG" | head -n1)
    if [[ -n "$PORT" ]]; then
        # Delete log immediately after reading
        rm -f "$TMP_LOG"
        break
    fi
done

if [[ -z "$PORT" ]]; then
    echo "Failed to detect Bore port. Tunnel may not have started yet."
    echo "Check the screen manually: screen -r $SCREEN_NAME"
    exit 1
fi

echo "VPS Booted successfully."
echo "SSH Address: google-vm.orbitsrv.qzz.io"
echo "Port: $PORT"
echo "Tunnel is running in screen session: $SCREEN_NAME"
echo "Reconnect to tunnel log with: screen -r $SCREEN_NAME"
