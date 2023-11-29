#!/bin/bash
source "${CICD_UTILS_SCRIPTS_PATH}"

message=$(
    cat <<EOF
\\@${PUSH_USERNAME}
⛔⛔ You are not allowed to forced push to branch ${PUSH_BRANCH_NAME}\\! ⛔⛔
Please make a pull request to branch ${PUSH_BRANCH_NAME} instead
EOF
)
send_message_telegram_default "$message"
exit 1
