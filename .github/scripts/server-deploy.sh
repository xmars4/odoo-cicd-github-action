#!/bin/bash
server_docker_compose_path=$1 # the path to folder container Odoo docker-compose.yml file
server_custom_addons_path=$2  # the absolute path to source code, also the git repository
server_config_file=$3         # the path to Odoo config file
git_private_key_file=$4       # private key on server use to authenticate on Github
server_odoo_url=$5            # odoo service url, to check service is up or not
server_odoo_db_name=$6

ssh_folder="$HOME/.ssh"
original_repo_remote_name="origin"
custom_repo_remote_name="origin-ssh"
custom_repo_host="ssh.cicd.github.com"
CUSTOM_ADDONS=

function get_list_addons {
    addons_path=$1
    addons=
    res=$(find "$addons_path" -maxdepth 2 -mindepth 2 -type f -name "__manifest__.py" -exec dirname {} \;)
    for dr in $res; do
        addon_name=$(basename $dr)
        if [[ -z $addons ]]; then
            addons="$addon_name"
        else
            addons="$addons,$addon_name"
        fi
    done

    echo $addons
}

check_git_repo_folder() {
    cd $server_custom_addons_path
    git status >/dev/null 2>&1
    if [[ $? -gt 0 ]]; then
        echo "Can't execute git commands because \"$PWD\" folder is not a git repository!"
        exit 1
    fi
}

get_original_remote_url() {
    remote_url=$(git remote get-url $original_repo_remote_name 2>/dev/null)
    if [ -z "$remote_url" ]; then
        other_repo_remote_name=$(git remote show | head -n 1)
        if [ -z "$other_repo_remote_name" ]; then
            exit 1
        fi
        remote_url=$(git remote get-url $other_repo_remote_name)
    fi
    echo "$remote_url"
}

add_custom_repo_remote() {
    repo_name=$1
    custom_remote_url="git@$custom_repo_host:$repo_name"
    git remote add $custom_repo_remote_name $custom_remote_url
    git remote set-url $custom_repo_remote_name $custom_remote_url
}

write_custom_git_host_to_ssh_config() {
    git_private_key_file_name=$(basename "$git_private_key_file")
    new_key_file_path="$ssh_folder/$git_private_key_file_name"
    cp "$git_private_key_file" "$ssh_folder"

    original_repo_host=$1
    config_value="
\n# Custom git host for CI/CD process
Host $custom_repo_host
  Hostname $original_repo_host
  IdentityFile $new_key_file_path
  IdentitiesOnly yes\n
    "
    if ! grep -q "Host $custom_repo_host" "$ssh_folder/config"; then
        echo -e "$config_value" >>"$ssh_folder/config"
    fi
}

setup_git_ssh_remote() {
    git remote remove $custom_repo_remote_name
    remote_url=$(get_original_remote_url)
    if ! [[ $remote_url =~ ^git@ ]]; then
        repo_name=$(echo "$remote_url" | sed "s/.*:\/\/[^/]*\///" | sed "s/\.git$//")
        repo_host=$(echo "$remote_url" | sed "s/\/[^/]*\/[^/]*$//" | sed "s/^.*\/\///")
        # re-build repo's ssh url
        # so we can setup and use git command authenticate by ssh private key
        remote_url="git@$repo_host:$repo_name"
    else
        repo_name=$(echo "$remote_url" | sed "s/.*://" | sed "s/\.git$//")
        repo_host=$(echo "$remote_url" | sed "s/^git@//" | sed "s/:.*//")
    fi
    add_custom_repo_remote $repo_name
    write_custom_git_host_to_ssh_config $repo_host
}

pull_latest_code() {
    current_branch=$(git branch --show-current)
    remote_url=$(get_original_remote_url)
    if [ -z $remote_url ]; then
        echo "Can't found any valid remote name of git repository in folder ${server_custom_addons_path}"
        exit 1
    fi

    # try to pull code with default options
    # if failed -> setup other remote ssh and try again
    git pull
    pull_success=$?

    # try to pull with custom remote name
    git pull $custom_repo_remote_name $current_branch
    pull_success=$?

    if [[ $pull_success -ne 0 ]]; then
        setup_git_ssh_remote
        git pull $custom_repo_remote_name $current_branch
    fi
}

set_list_addons() {
    declare -g CUSTOM_ADDONS
    CUSTOM_ADDONS=$(get_list_addons "$server_custom_addons_path")
}

update_config_file() {
    sed -i "s/^[ #]*command\s*=.*//g" $server_config_file
    sed '/^$/N;/^\n$/D' $server_config_file >temp && mv temp $server_config_file
    echo -e "\ncommand = -d ${server_odoo_db_name} -i ${CUSTOM_ADDONS} -u ${CUSTOM_ADDONS}" >>"${server_config_file}"
}

reset_config_file() {
    sed -i "s/^[ #]*command\s*=.*//g" $server_config_file
    sed '/^$/N;/^\n$/D' $server_config_file >temp && mv temp $server_config_file
    cd "${server_docker_compose_path}"
    docker compose restart
}

update_odoo_services() {
    cd "${server_docker_compose_path}"
    docker compose pull
    docker compose down
    docker compose up -d --build
}

function get_odoo_login_url() {
    url=$1
    scheme=$(echo $url | awk -F:// '{print $1}')
    domain_port=$(echo $url | sed -n 's~^https\?://\([^/]\+\).*~\1~p')
    echo "${scheme}://${domain_port}/web/login"
}

function wait_until_odoo_available {
    echo "Hang on, Modules are being updated ..."
    # Assuming each addon needs 60s to be updated
    # -> we can calculate maximum total sec we have to wait until Odoo is up and running
    server_odoo_login_url=$(get_odoo_login_url $server_odoo_url)
    ESITATE_TIME_EACH_ADDON=30
    IFS=',' read -ra separate_addons_list <<<$CUSTOM_ADDONS
    total_addons=${#separate_addons_list[@]}
    # each block wait 5s
    maximum_count=$(((total_addons * ESITATE_TIME_EACH_ADDON) / 5))
    count=1
    while (($count <= $maximum_count)); do
        http_status=$(echo "foo|bar" | { wget --connect-timeout=5 --server-response --spider --quiet "${server_odoo_login_url}" 2>&1 | awk 'NR==1{print $2}' || true; })
        if [[ $http_status = '200' ]]; then
            return # Odoo service is fully up and running
        fi
        ((count++))
        sleep 5
    done
    exit 1 # Odoo service is not running
}

main() {
    check_git_repo_folder
    pull_latest_code
    set_list_addons
    update_config_file
    update_odoo_services
    wait_until_odoo_available
    reset_config_file
}

main
