#!/bin/bash

# Configuration
INSTALL_DIR="/opt/gnss-tecmon"
BIN_DIR="${INSTALL_DIR}/bin"
REPO_URL="https://github.com/tomojitakasu/RTKLIB.git"
CLONE_DIR="/tmp/RTKLIB"

# Make sure this is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g. sudo $0)"
  exit 1
fi

echo "Installing dependencies..."
apt update && apt install -y build-essential git libqt5serialport5-dev qtbase5-dev

echo "Cloning RTKLIB from GitHub..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"

echo "Building RTKLIB command-line tools..."
mkdir -p "$BIN_DIR"

cd "$CLONE_DIR/app/str2str/gcc" && make clean && make && cp str2str "$BIN_DIR/"
cd "$CLONE_DIR/app/convbin/gcc" && make clean && make && cp convbin "$BIN_DIR/"
cd "$CLONE_DIR/app/rnx2rtkp/gcc" && make clean && make && cp rnx2rtkp "$BIN_DIR/"
cd "$CLONE_DIR/app/rnx2crx/gcc" && make clean && make && cp rnx2crx "$BIN_DIR/"

chmod +x "$BIN_DIR"/*

echo "RTKLIB tools installed to $BIN_DIR"

# Optional: verify installation
"$BIN_DIR/str2str" -h | head -n 1
"$BIN_DIR/convbin" -h | head -n 1
