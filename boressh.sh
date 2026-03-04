#!/bin/bash

echo "Starting free SSH IP..."

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or using sudo!"
    exit 1
fi

# Install bore if missing
if ! command -v bore &> /dev/null; then
    echo "bore not found, installing Rust and bore-cli..."
    
    # Install build dependencies
    apt update
    apt install build-essential pkg-config libssl-dev curl -y || { echo "Failed to install dependencies"; exit 1; }

    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env

    # Install nightly and set default
    rustup install nightly
    rustup default nightly

    # Install bore-cli
    cargo install bore-cli || { echo "Failed to install bore-cli"; exit 1; }
fi

# Run bore
echo "Starting bore tunnel..."
BORE_OUTPUT=$(bore local 22 --to bore.pub 2>&1)

# Extract port
PORT=$(echo "$BORE_OUTPUT" | grep -oP 'remote_port=\K[0-9]+')

# Display result
if [ -n "$PORT" ]; then
    echo ""
    echo "VPS Booted successfully."
    echo "SSH Address:"
    echo "IP: google-vm.orbitsrv.qzz.io"
    echo "Port: $PORT"
else
    echo "Failed to start bore tunnel. Output:"
    echo "$BORE_OUTPUT"
fi
