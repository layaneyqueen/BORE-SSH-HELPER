#!/bin/bash

echo "Starting free SSH IP..."

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root or using sudo!"
   exit 1
fi

# Check and install dependencies for Bore
if ! command -v bore &>/dev/null; then
    echo "Bore not found, installing dependencies..."
    apt update
    apt install -y build-essential pkg-config libssl-dev curl screen
    if [[ $? -ne 0 ]]; then
        echo "Failed to install dependencies. Please check your package manager."
        exit 1
    fi

    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    rustup install nightly
    rustup default nightly

    echo "Installing Bore CLI..."
    cargo install bore-cli
    if [[ $? -ne 0 ]]; then
        echo "Failed to install Bore CLI."
        exit 1
    fi
fi

# Ensure screen exists
if ! command -v screen &>/dev/null; then
    echo "Please install 'screen' first."
    exit 1
fi

SCREEN_NAME="bore_ssh_tunnel"
LOG_FILE="/tmp/bore_ssh_tunnel.log"

# Kill old screen if exists
screen -S "$SCREEN_NAME" -X quit 2>/dev/null

# Start Bore in a detached screen, log output
echo "Starting bore tunnel..."
screen -dmS "$SCREEN_NAME" bash -c "bore local 22 --to bore.pub | tee $LOG_FILE"

# Wait for remote_port
PORT=""
while [[ -z "$PORT" ]]; do
    if [[ -f "$LOG_FILE" ]]; then
        PORT=$(grep -oP 'remote_port=\K[0-9]+' "$LOG_FILE")
    fi
    sleep 1
done

echo "VPS Booted successfully."
echo "SSH Address: google-vm.orbitsrv.qzz.io"
echo "Port: $PORT"
echo "Tunnel is running in screen session: $SCREEN_NAME"
echo "You can reconnect to the tunnel log with: screen -r $SCREEN_NAME"
