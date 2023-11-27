#!/bin/bash
source "${PIPELINE_UTILS_SCRIPT_PATH}"

function update_config_file {
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    sed -i "s/^\s*db_name\s*.*//g" $CONFIG_FILE
}

function main() {
    update_config_file
}

main "$@"
