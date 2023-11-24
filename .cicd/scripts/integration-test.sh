#!/bin/bash
source "${PIPELINE_UTILS_SCRIPT_PATH}"

populate_variables() {
    declare -g received_backup_file_path=$1
    declare -g odoo_container_store_backup_folder="/tmp/odoo/restore"
    declare -g extracted_backup_folder_name=$(basename $received_backup_file_path | sed "s/.tar.gz//")

    declare -g db_host=$(get_config_value "db_host")
    declare -g db_host=${db_host:-'db'}
    declare -g db_port=$(get_config_value "db_port")
    declare -g db_port=${db_port:-'5432'}
    declare -g db_user=$(get_config_value "db_user")
    declare -g db_password=$(get_config_value "db_password")
    declare -g data_dir=$(get_config_value "data_dir")
    declare -g data_dir=${data_dir:-'/var/lib/odoo'}
}

get_config_value() {
    param=$1
    grep -q -E "^\s*\b${param}\b\s*=" "$CONFIG_FILE"
    if [[ $? == 0 ]]; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$CONFIG_FILE" | cut -d " " -f3 | sed 's/["\n\r]//g')
    fi
    echo "$value"
}

function update_config_file_before_restoration {
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    sed -i "s/^\s*db_name\s*.*//g" $CONFIG_FILE
}

function update_config_file_after_restoration {
    install_addons=$(get_list_addons "$ODOO_CUSTOM_ADDONS_PATH")
    custom_addons=$(get_list_addons_should_run_test "$ODOO_CUSTOM_ADDONS_PATH")
    tagged_custom_addons=$(echo $custom_addons | sed "s/,/,\//g" | sed "s/^/\//")
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    echo -en "\ncommand = \
    --stop-after-init \
    --workers 0 \
    --database $ODOO_TEST_DATABASE_NAME \
    --logfile $LOG_FILE \
    --log-level info \
    --update $custom_addons \
    --init $install_addons \
    --test-tags ${tagged_custom_addons}\n" >>$CONFIG_FILE
}

copy_backup() {
    odoo_container_id=$(get_odoo_container_id)
    received_backup_file_name=$(basename $received_backup_file_path)
    docker_odoo_exec "mkdir -p $odoo_container_store_backup_folder"
    docker cp "$received_backup_file_path" $odoo_container_id:$odoo_container_store_backup_folder
    docker_odoo_exec "cd $odoo_container_store_backup_folder && tar -xzf $received_backup_file_name"
}

config_psql_without_password() {
    pgpass_path="~/.pgpass"
    docker_odoo_exec "touch $pgpass_path ; echo $db_host:$db_port:postgres:$db_user:$db_password > $pgpass_path ; chmod 0600 $pgpass_path"
    docker_odoo_exec "echo '' >> $pgpass_path"
    docker_odoo_exec "echo $db_host:$db_port:\"$ODOO_TEST_DATABASE_NAME\":$db_user:$db_password >> $pgpass_path"
}

start_instance() {
    update_config_file_before_restoration
    docker_compose_clean # remove old test instance
    docker_compose up -d
}

restart_instance() {
    update_config_file_after_restoration
    docker_compose restart
}

create_empty_db() {
    docker_odoo_exec "psql -h \"$db_host\" -U $db_user postgres -c \"CREATE DATABASE ${ODOO_TEST_DATABASE_NAME} ENCODING 'UNICODE' LC_COLLATE 'C' TEMPLATE template0;\""
}

restore_db() {
    sql_dump_path="${odoo_container_store_backup_folder}/${extracted_backup_folder_name}/dump.sql"
    docker_odoo_exec "psql -h \"$db_host\" -U $db_user $ODOO_TEST_DATABASE_NAME < $sql_dump_path >/dev/null"
}

restore_filestore() {
    filestore_backup_name="filestore.tar.gz"
    backup_filestore_path="${odoo_container_store_backup_folder}/${extracted_backup_folder_name}/$filestore_backup_name"
    filestore_path="$data_dir/filestore"
    docker_odoo_exec "mkdir -p $filestore_path;cp $backup_filestore_path $filestore_path;cd $filestore_path;tar -xzf $filestore_backup_name;rm -rf $filestore_backup_name"
    docker_odoo_exec "cd $filestore_path && find . -mindepth 1 -maxdepth 1 -type d -exec mv {} $ODOO_TEST_DATABASE_NAME \;"
}

restore_backup() {
    start_instance
    copy_backup
    config_psql_without_password
    create_empty_db
    restore_db
    restore_filestore
    restart_instance
    wait_until_odoo_shutdown
}

analyze_log_file() {
    # in case Odoo don't have any ERROR -> log file will be not generated
    # so no need to analyze log anymore
    [ -f ${LOG_FILE_OUTSIDE} ]
    if [ $? -ne 0 ]; then
        return 0
    fi

    grep -m 1 -P '^[0-9-\s:,]+(ERROR|CRITICAL)' $LOG_FILE_OUTSIDE >/dev/null 2>&1
    error_exist=$?
    if [ $error_exist -eq 0 ]; then
        exit 1
    fi
}

main() {
    populate_variables $@
    restore_backup
    analyze_log_file
}

main $@
