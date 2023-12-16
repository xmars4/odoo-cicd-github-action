#!/bin/bash
source "${CICD_UTILS_SCRIPTS_PATH}"

function main {
    if [[ $PR_EVENT_NAME == 'closed' ]] && [[ $PR_WAS_MERGED == 'false' ]]; then
        echo "PR#${PR_NUMBER} was closed manually, stopping this workflow now!"
        exit 1
    fi
    custom_addons=$(get_list_addons $ODOO_CUSTOM_ADDONS_PATH)
    if [[ -z $custom_addons ]]; then
        echo "Can't find any custom addons, stopping this workflow now!"
        exit 1
    fi
}

main
