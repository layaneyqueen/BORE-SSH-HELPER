#!/bin/bash

echo "Starting free SSH IP..."

# Ensure screen is installed
if ! command -v screen &>/dev/null; then
    echo "Installing screen..."
    sudo apt update
    sudo apt install screen -y || { echo "Please run as root or using sudo!"; exit 1; }
fi

# Install bore if missing
if ! command -v bore &>/dev/null; then
    echo "Installing build dependencies..."
    sudo apt update
    sudo apt install build-essential pkg-config libssl-dev curl -y || { echo "Please run as root or using sudo!"; exit 1; }

    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    rustup install nightly
    rustup default nightly

    echo "Installing bore-cli..."
    cargo install bore-cli
fi

# Start bore in a detached screen session and log output to a temp file
SCREEN_NAME="bore_ssh_tunnel"
TMP_LOG="/tmp/${SCREEN_NAME}.log"

# Remove old log if exists
[ -f "$TMP_LOG" ] && rm "$TMP_LOG"

# Kill previous screen session if exists
if screen -list | grep -q "$SCREEN_NAME"; then
    screen -S "$SCREEN_NAME" -X quit
fi

# Start bore in screen and log output
screen -dmS "$SCREEN_NAME" bash -c "bore local 22 --to bore.pub | tee $TMP_LOG"

# Wait until remote_port line appears
echo "Starting bore tunnel..."
PORT=""
for i in {1..15}; do
    if grep -q 'remote_port=' "$TMP_LOG"; then
        PORT=$(grep -oP 'remote_port=\K[0-9]+' "$TMP_LOG" | head -n1)
        break
    fi
    sleep 1
done

if [ -z "$PORT" ]; then
    echo "Failed to get remote port. Check the screen log with: screen -r $SCREEN_NAME"
    exit 1
fi

# Print the SSH info
echo "VPS Booted successfully."
echo "SSH Address: google-vm.orbitsrv.qzz.io"
echo "Port: $PORT"
