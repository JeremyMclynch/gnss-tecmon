#!/bin/bash

# Metadata
sta_name="STATION NAME"
country_name="COUNTRY CODE"
rec_type="RECEIVER MODEL"
ant_type="ANTENNA MODEL"
observer="OBSERVER NAME"

# Directory structure
INSTALL_PATH="/opt/gnss-tecmon"
BIN_PATH="${INSTALL_PATH}/bin"
RAW_PATH="${INSTALL_PATH}/data/raw"
ARCH_PATH="${INSTALL_PATH}/data/archive"
RUN_PATH="${INSTALL_PATH}/run"
LOG_PATH="${INSTALL_PATH}/logs"

# Ensure key directories exist
mkdir -p "$RAW_PATH" "$ARCH_PATH" "$RUN_PATH" "$LOG_PATH"

# Logging
MAIN_LOG="${LOG_PATH}/convert_main.log"

# Locking
LOCK_FILE="${RUN_PATH}/convert.lock"
exec {lock_fd}>"$LOCK_FILE" || exit 1
flock -n "$lock_fd" || {
    echo "$(date -u): ERROR: convert.sh is already running." >> "$MAIN_LOG"
    exit 1
}

echo "$(date -u): Starting GNSS conversion process" >> "$MAIN_LOG"

# How many hours before current time to start processing
dt_shift_hr=1
max_days_back=3
dt_last_hr=$(date -u -d "-${dt_shift_hr} hour")
hrs_back=$((max_days_back * 24))

for ((i = 0; i < hrs_back; i++)); do
    dt_iter=$(date -u -d "${dt_last_hr} -${i} hour")
    file_mask=$(date -u -d "${dt_iter}" +"%Y%m%d_%H")
    epo_beg=$(date -u -d "${dt_iter}" +"%Y-%m-%d_%H")0000
    yr=$(date -u -d "${dt_iter}" +"%Y")
    hr=$(date -u -d "${dt_iter}" +"%H")
    doy=$(date -u -d "${dt_iter}" +"%j")

    files=$(find "$RAW_PATH" -type f -name "${file_mask}*.ubx")
    in_files=""

    for data_file in $files; do
        ts_suffix=$(basename "$data_file" | cut -c 10-13)  # Extract HHMM from filename
        out_file="${RAW_PATH}/${sta_name}00${country_name}_R_${ts_suffix}${doy}${hr}_01H_01S_MO.obs"

        echo "$(date -u): Converting $data_file to $out_file" >> "$MAIN_LOG"

        "$BIN_PATH/convbin" -os -od -oi -r ubx -v 3.04 \
            "$data_file" -hm "$sta_name" -hr "Unknown/${rec_type}" \
            -ha "Unknown/${ant_type}" -ho "$observer" -o "$out_file"

        in_files="${in_files} ${out_file}"
    done

    if [ -n "$in_files" ]; then
        rnx_out_file="${RAW_PATH}/${sta_name}00${country_name}_R_${yr}${doy}${hr}00_01H_01S_MO.rnx"

        echo "$(date -u): Splicing files into $rnx_out_file" >> "$MAIN_LOG"
        "$BIN_PATH/gfzrnx_2.1.0_armlx64" -finp ${in_files} -epo_beg "$epo_beg" -d 3600 -fout "$rnx_out_file" -f

        echo "$(date -u): Compressing $rnx_out_file" >> "$MAIN_LOG"
        "$BIN_PATH/rnx2crx" -f "$rnx_out_file"
        gzip -f "${rnx_out_file%rnx}crx"

        # Cleanup and archive
        rm -f "$RAW_PATH"/*.obs "$RAW_PATH"/*.rnx "$RAW_PATH/${file_mask}"*.ubx
        mkdir -p "$ARCH_PATH/$yr/$doy"
        mv -f "$RAW_PATH"/*.gz "$ARCH_PATH/$yr/$doy/"
    fi
done

echo "$(date -u): Conversion complete." >> "$MAIN_LOG"

# Release lock
flock -u "$lock_fd"
