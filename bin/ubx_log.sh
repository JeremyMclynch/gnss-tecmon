#!/bin/bash

# Base install path
INSTALL_PATH="/opt/gnss-tecmon"

# Subdirectories following the structured layout
BIN_PATH="${INSTALL_PATH}/bin"
DATA_PATH="${INSTALL_PATH}/data/raw"
CONFIG_PATH="${INSTALL_PATH}/etc"
LOG_PATH="${INSTALL_PATH}/logs"
RUN_PATH="${INSTALL_PATH}/run"

# Ensure required directories exist
mkdir -p "$DATA_PATH" "$LOG_PATH" "$RUN_PATH"

# Lock file path (ephemeral, runtime-only)
LOCK_FILE="${RUN_PATH}/ubx_log.lock"

# Log file path (optional)
MAIN_LOG="${LOG_PATH}/ubx_log_main.log"

# Acquire exclusive lock using flock
exec {lock_fd}>"$LOCK_FILE" || exit 1
flock -n "$lock_fd" || {
    echo "$(date): ERROR: ubx_log.sh already running." >> "$MAIN_LOG"
    exit 1
}

# Start logging
echo "$(date): Starting str2str logging..." >> "$MAIN_LOG"

"${BIN_PATH}/str2str" \
    -in serial://ttyACM0#ubx \
    -out "${DATA_PATH}/%Y%m%d_%H%M%S.ubx::S=1" \
    -c "${CONFIG_PATH}/ubx.dat"

# End logging
echo "$(date): str2str process exited." >> "$MAIN_LOG"

# Release lock
flock -u "$lock_fd"
