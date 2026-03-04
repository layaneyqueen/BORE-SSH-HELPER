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
echo "Starting free SSH IP..."

# Ensure screen exists
if ! command -v screen &>/dev/null; then
    echo "Please install 'screen' first."
    exit 1
fi

# Start bore in a screen, redirect output to log
SCREEN_NAME="bore_ssh_tunnel"
LOG_FILE="/tmp/bore_ssh_tunnel.log"

# Kill old screen if exists
screen -S "$SCREEN_NAME" -X quit 2>/dev/null

# Start bore in a detached screen
screen -dmS "$SCREEN_NAME" bash -c "bore local 22 --to bore.pub | tee $LOG_FILE"

# Wait for the port to appear in the log
echo "Starting bore tunnel..."
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
