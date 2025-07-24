#!/bin/bash
INSTALL_PATH="/opt/gnss-tecmon"
CRON_JOB="@reboot $INSTALL_PATH/bin/ubx_log.sh >> $INSTALL_PATH/logs/ubx_cron.log 2>&1"

if ! crontab -l 2>/dev/null | grep -Fxq "$CRON_JOB"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job installed."
else
    echo "Cron job already exists."
fi
