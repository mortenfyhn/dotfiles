#!/usr/bin/env bash

# Prints a Sublime project file showing exactly the files tracked in the dotfiles
# repo, so the sidebar isn't buried in untracked stuff in $HOME. Regenerate after
# tracking new files:
#
#     ~/.dotfiles-update-project.sh > ~/.dotfiles.sublime-project
#
# .ci.sh checks the committed project file still matches this output.

set -Eeuo pipefail

dots() { git --git-dir="$HOME"/.dotfiles --work-tree="$HOME" "$@"; }

# A Sublime pattern starting with // is compared against the path relative to the
# project root, so these match the tracked files and nothing else.
# LC_ALL=C keeps the order identical everywhere, so the .ci.sh diff below only
# fires on real drift and not on a different locale.
names() { dots ls-files | sed 's|^|//|' | LC_ALL=C sort -u; }

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
