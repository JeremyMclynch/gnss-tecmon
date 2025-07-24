#!/bin/bash

# Config
APP_NAME="gnss-tecmon"
LOG_DIR="/opt/$APP_NAME/logs"
LOG_FILES=(
    "$LOG_DIR/convert_main.log"
    "$LOG_DIR/ubx_log_main.log"
)
LOGROTATE_CONF="/etc/logrotate.d/$APP_NAME"

# Ensure this script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g. sudo $0)"
  exit 1
fi

# Create the logrotate configuration
{
  for log_file in "${LOG_FILES[@]}"; do
    echo "$log_file {"
    echo "    size 1M"
    echo "    rotate 7"
    echo "    compress"
    echo "    delaycompress"
    echo "    missingok"
    echo "    notifempty"
    echo "    copytruncate"
    echo "}"
    echo
  done
} > "$LOGROTATE_CONF"

# Set permissions
chmod 644 "$LOGROTATE_CONF"

echo "Logrotate config written to $LOGROTATE_CONF"
echo "   Logs:"
for f in "${LOG_FILES[@]}"; do
  echo "   - $f"
done

# Optional: test the logrotate config
read -p "Do you want to test logrotate now? [y/N] " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  logrotate -d "$LOGROTATE_CONF"
fi
