#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
show_separator "Start analyzing log file"

function analyze_log {
    # we get all info from this test -> just send log file to somewhere
    # no need to analyze anything
    [ -f ${LOG_FILE_OUTSIDE} ]
    if [ $? -ne 0 ]; then
        return 0
    fi

    grep -m 1 -P '^[0-9-\s:,]+(ERROR|CRITICAL)' $LOG_FILE_OUTSIDE >/dev/null 2>&1
    error_exist=$?
    if [ $error_exist -eq 0 ]; then
        message="🐞The pylint test result for [PR \\#$PR_NUMBER]($PR_URL)🐞"
        send_file_telegram "$TELEGRAM_TOKEN" "$TELEGRAM_CHANNEL_ID" "$LOG_FILE_OUTSIDE" "$message"
        return 1
    fi
}

wait_until_odoo_shutdown
analyze_log
