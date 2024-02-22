#!/bin/bash

populate_variables() {
    declare -g docker_folder=$1
    declare -g odoo_image=$2
    declare -g db_image=$3
    declare -g odoo_container_store_backup_folder="/tmp/odoo/restore"
    declare -g extracted_backup_folder_name=odoo

    declare -g db_host=$(get_config_value "db_host")
    declare -g db_host=${db_host:-'db'}
    declare -g db_port=$(get_config_value "db_port")
    declare -g db_port=${db_port:-'5432'}
    declare -g db_user=$(get_config_value "db_user")
    declare -g db_password=$(get_config_value "db_password")
    declare -g data_dir=$(get_config_value "data_dir")
    declare -g data_dir=${data_dir:-'/var/lib/odoo'}
}

start_db_container() {
    cd ${docker_folder}
    docker run -d \
        -p 5432:5432 -v ./postgresql:/etc/postgresql -e POSTGRES_PASSWORD=odoo -e POSTGRES_USER=odoo -e POSTGRES_DB=postgres \
        ${db_image} \
        -c 'config_file=/etc/postgresql/postgresql.conf'
}

start_odoo_container() {
    addons_path=$(readlink -f ${docker_folder}/../..)
    docker run -d \
        --mount type=bind,source=${addons_path},target=/mnt/custom-addons \
        -v ./etc:/etc/odoo \
        -v ./logs:/var/log/odoo \
        ${odoo_image}
}

main() {
    populate_variables "$@"
    start_db_container
    start_odoo_container
}

main "$@"
