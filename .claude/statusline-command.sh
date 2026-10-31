#!/usr/bin/env bash
# Show the session title: the /rename title if set, else Claude Code's auto-generated title.
transcript=$(jq -r '.transcript_path // empty')
[[ -f $transcript ]] || exit 0

title=$(grep -h '"type":"custom-title"' "$transcript" | tail -1 | jq -r '.customTitle // empty')
[[ -n $title ]] || title=$(grep -h '"type":"ai-title"' "$transcript" | tail -1 | jq -r '.aiTitle // empty')
[[ -n $title ]] && printf '\e[1;38;2;100;149;237m%s\e[0m' "$title"
