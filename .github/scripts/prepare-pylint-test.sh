#!/bin/bash

source "${CICD_UTILS_SCRIPTS_PATH}"

function update_config_file {
    sed -i "s/^\s*command\s*.*//g" $ODOO_CONFIG_FILE
    sed -i "s/^\s*without_demo\s*.*//g" $ODOO_CONFIG_FILE

    echo -en "\ncommand = \
    --stop-after-init \
    --workers 0 \
    --database $ODOO_TEST_DATABASE_NAME \
    --logfile "$ODOO_LOG_FILE_CONTAINER" \
    --load base,web \
    --init test_lint \
    --test-tags /test_lint \
    --log-level error" >>$ODOO_CONFIG_FILE
    echo " " >>$ODOO_CONFIG_FILE
}

function main {
    update_config_file
    update_services_tag_docker_compose
}

main "$@"
