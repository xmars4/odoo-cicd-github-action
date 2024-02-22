#!/bin/bash

start_db_container() {
    docker run -d \
        -p 5432:5432 \
        --mount type=bind,source=$DOCKER_FOLDER/postgresql,target=/etc/postgresql \
        -e POSTGRES_PASSWORD=odoo -e POSTGRES_USER=odoo -e POSTGRES_DB=postgres \
        $DB_IMAGE_TAG \
        -c 'config_file=/etc/postgresql/postgresql.conf'
}

start_odoo_container() {
    docker run -d \
        --mount type=bind,source=$ODOO_ADDONS_PATH,target=/mnt/custom-addons \
        --mount type=bind,source=$DOCKER_FOLDER/etc,target=/etc/odoo \
        --mount type=bind,source=$DOCKER_FOLDER/logs,target=/var/log/odoo \
        $ODOO_IMAGE_TAG
}

start_containers() {
    start_db_container
    start_odoo_container
}

main() {

}

main
