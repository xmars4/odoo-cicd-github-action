#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
show_separator "Start analyzing log file"

function main() {
    wait_until_odoo_shutdown
    failed_message=$(
        cat <<EOF
🐞 A few pylint test cases of the [PR \\#$PR_NUMBER]($PR_URL) did not pass\\! 🐞
Please take a look at the attached log file🔬
EOF
    )
    analyze_log $failed_message
}

main