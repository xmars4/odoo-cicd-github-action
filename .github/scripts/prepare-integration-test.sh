#!/bin/bash
source "${CICD_UTILS_SCRIPTS_PATH}"

function update_config_file {
    sed -i "s/^\s*command\s*.*//g" $ODOO_CONFIG_FILE
    sed -i "s/^\s*db_name\s*.*//g" $ODOO_CONFIG_FILE
}

function main() {
    update_config_file
    update_services_tag_docker_compose
    #fixme: remove below lines
    ls -lah /tmp
    cat $ODOO_DOCKER_COMPOSE_FILE

}

main "$@"
