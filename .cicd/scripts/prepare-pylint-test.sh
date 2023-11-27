#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"

function update_config_file {
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    sed -i "s/^\s*without_demo\s*.*//g" $CONFIG_FILE

    echo -en "\ncommand = \
    --stop-after-init \
    --workers 0 \
    --database $ODOO_TEST_DATABASE_NAME \
    --logfile "$LOG_FILE" \
    --load base,web \
    --init test_lint \
    --test-tags /test_lint \
    --log-level error" >>$CONFIG_FILE
    echo " " >>$CONFIG_FILE
}

function main {
    update_config_file
    copy_requirements_txt_file
}

main "$@"
