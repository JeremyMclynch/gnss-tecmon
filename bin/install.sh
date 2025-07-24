#!/bin/bash

set -e

INSTALL_PATH="/opt/gnss-tecmon"
BIN_PATH="$INSTALL_PATH/bin"
ETC_PATH="$INSTALL_PATH/etc"
LOG_PATH="$INSTALL_PATH/logs"
LOG_FILE="$LOG_PATH/install.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_PATH"

# Log function
log() {
    echo "$(date -u +"%Y-%m-%d %H:%M:%S") [INSTALL] $*" | tee -a "$LOG_FILE"
}

log "Starting GNSS-TecMon installation."

# Step 1: Generate directories
log "Running gen_dirs.sh..."
bash ./gen_dirs.sh >> "$LOG_FILE" 2>&1

# Step 2: Move scripts to appropriate locations
log "Moving convert.sh and ubx_log.sh to $BIN_PATH..."
mv convert.sh ubx_log.sh "$BIN_PATH/" >> "$LOG_FILE" 2>&1

log "Moving ubx.dat to $ETC_PATH..."
mv ubx.dat "$ETC_PATH/" >> "$LOG_FILE" 2>&1

# Step 3: Install RTKLIB binaries
log "Running install_rtklib.sh..."
bash ./install_rtklib.sh >> "$LOG_FILE" 2>&1

# Step 4: Setup log rotation
log "Running log_rotate.sh..."
bash ./log_rotate.sh >> "$LOG_FILE" 2>&1

# Step 5: Setup UBX cron job
log "Running ubx_cron_setup.sh..."
bash ./ubx_cron_setup.sh >> "$LOG_FILE" 2>&1

log "Installation complete."
