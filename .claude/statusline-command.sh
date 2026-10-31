#!/usr/bin/env bash
title=$(bash ~/.claude/session-title.sh)
[[ -n $title ]] && printf '\e[1;38;2;100;149;237m%s\e[0m' "$title"
