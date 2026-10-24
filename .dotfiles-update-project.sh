#!/usr/bin/env bash

# Prints a Sublime project file showing tracked dotfiles plus .zshrc.local,
# so the sidebar isn't buried in untracked stuff in $HOME. Regenerate after
# tracking new files:
#
#     ~/.dotfiles-update-project.sh > ~/.dotfiles.sublime-project
#
# .dotfiles-check.sh makes sure that the committed project file is the same as
# this output.

set -Eeuo pipefail

cd "$(dirname "$0")"

dots() { git --git-dir="$HOME"/.dotfiles --work-tree="$HOME" "$@"; }

# A Sublime pattern starting with // is compared against the path relative to the
# project root, so these match tracked files plus the machine-local .zshrc.local.
# LC_ALL=C gives the same sort order with all locales. Thus, the diff in
# .dotfiles-check.sh fails only when the tracked files change.
names() {
    {
        dots ls-files
        echo .zshrc.local
    } | sed 's|^|//|' | LC_ALL=C sort -u
}

# Every directory holding a tracked file, plus its ancestors: Sublime hides a
# folder unless the folder itself matches.
folders() {
    dots ls-files | while read -r file; do
        dir=$(dirname "$file")
        while [[ "$dir" != "." ]]; do
            echo "//$dir"
            dir=$(dirname "$dir")
        done
    done | LC_ALL=C sort -u
}

# Turn one item per line into indented, quoted, comma-separated JSON entries.
json_list() { sed -e 's/.*/                "&",/' -e '$ s/,$//'; }

cat <<EOF
{
    "folders":
    [
        {
            "path": ".",
            "folder_include_patterns":
            [
$(folders | json_list)
            ],
            "file_include_patterns":
            [
$(names | json_list)
            ]
        }
    ]
}
EOF
