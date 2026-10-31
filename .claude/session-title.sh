#!/usr/bin/env bash
# Read Claude Code hook/status JSON on stdin. Print the auto-generated session title.
transcript=$(jq -r '.transcript_path // empty')
[[ -f $transcript ]] || exit 0
grep -h '"type":"ai-title"' "$transcript" | tail -1 | jq -r '.aiTitle // empty' | tr -d '\n'
