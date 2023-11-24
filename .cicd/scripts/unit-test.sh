#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
cd $ODOO_WORKSPACE

ODOO_CONTAINER_ID=$(get_odoo_container_id)
show_separator "Start analyzing log file"

function analyze_log {
    # in case Odoo don't have any ERROR -> log file will be not generated
    # so no need to analyze log anymore
    [ -f ${LOG_FILE_OUTSIDE} ]
    if [ $? -ne 0 ]; then
        return 0
    fi

    grep -m 1 -P '^[0-9-\s:,]+(ERROR|CRITICAL)' $LOG_FILE_OUTSIDE >/dev/null 2>&1
    error_exist=$?
    if [ $error_exist -eq 0 ]; then
        message=$(
            cat <<EOF
🐞The [PR \\#$PR_NUMBER]($PR_URL) check has failed\\!🐞
Please take a look at the attached log file🔬
EOF
        )
        send_file_telegram "$TELEGRAM_TOKEN" "$TELEGRAM_CHANNEL_ID" "$LOG_FILE_OUTSIDE" "$message"
        return 1
    fi
}

wait_until_odoo_shutdown
analyze_log
