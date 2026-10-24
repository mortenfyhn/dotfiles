#!/usr/bin/env bash

# Send an email about a failed CI job through ntfy.sh. The email goes to the
# verified address of the ntfy account that owns $NTFY_TOKEN.

set -Eeuo pipefail

curl --silent --show-error --fail \
    -H "Authorization: Bearer $NTFY_TOKEN" \
    -H "Email: yes" \
    -H "Title: Dotfiles CI failed" \
    -d "$SEMAPHORE_BLOCK_NAME failed on $SEMAPHORE_GIT_BRANCH: https://fyhn.semaphoreci.com/workflows/$SEMAPHORE_WORKFLOW_ID" \
    https://ntfy.sh/mortenfyhn-dotfiles-ci
