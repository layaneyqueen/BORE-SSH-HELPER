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

# Start bore in a detached screen session
SCREEN_NAME="bore_ssh_tunnel"

# Kill previous screen session if exists
if screen -list | grep -q "$SCREEN_NAME"; then
    screen -S "$SCREEN_NAME" -X quit
fi

# Start bore in screen and capture port
screen -dmS $SCREEN_NAME bash -c 'bore local 22 --to bore.pub'

# Wait a bit and get the remote port
sleep 5
PORT=$(screen -ls $SCREEN_NAME -X hardcopy /tmp/bore_output.txt && grep -oP 'remote_port=\K[0-9]+' /tmp/bore_output.txt | head -n1)

# Print the SSH info
echo "VPS Booted successfully."
echo "SSH Address: google-vm.orbitsrv.qzz.io"
echo "Port: $PORT"
