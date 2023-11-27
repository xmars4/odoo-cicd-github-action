#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
show_separator "Start analyzing log file"

function main() {
    type=$1
    wait_until_odoo_shutdown
    failed_message=$(
        cat <<EOF
🐞 $type: A few unit test cases for the [PR \\#$PR_NUMBER]($PR_URL) did not pass\\! 🐞
Please take a look at the attached log file🔬
EOF
    )
    analyze_log $failed_message
}

main $@
