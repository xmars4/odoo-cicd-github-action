#!/bin/bash

source "${CICD_UTILS_SCRIPTS_PATH}"
show_separator "Start analyzing log file"

function main() {
    wait_until_odoo_shutdown
    failed_message=$(
        cat <<EOF
🐞 A few pylint test cases of the [PR \\#$PR_NUMBER]($PR_URL) did not pass\\! 🐞
Please take a look at the attached log file🔬
EOF
    )
    analyze_log_file "$failed_message"
}

main
