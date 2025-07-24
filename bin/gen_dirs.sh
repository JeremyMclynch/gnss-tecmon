#!/bin/bash

# Configuration
BASE_DIR="/opt/gnss-tecmon"
DIRS=(
    "bin"
    "lib"
    "etc"
    "logs"
    "data"
    "cache"
    "tmp"
    "run"
    "share"
    "resources"
)

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo." >&2
    exit 1
fi

echo "Setting up directory layout in $BASE_DIR..."

# Create the base directory if needed
if [ ! -d "$BASE_DIR" ]; then
    mkdir -p "$BASE_DIR"
    echo "Created base directory: $BASE_DIR"
fi

# Create subdirectories
for dir in "${DIRS[@]}"; do
    mkdir -p "$BASE_DIR/$dir"
    echo "Created: $BASE_DIR/$dir"
done

# Set ownership and general permissions
chown -R root:root "$BASE_DIR"
chmod -R 755 "$BASE_DIR"

# Make writable directories group-writable (adjust as needed)
for writable in logs data cache tmp run; do
    chmod 775 "$BASE_DIR/$writable"
    echo "Set writable permissions: $BASE_DIR/$writable"
done

echo "✅ Application directory structure is ready at $BASE_DIR"
