#!/usr/bin/env bash

export CC=clang
export CXX=clang++
export PATH="/usr/lib/ccache:$PATH"
export ZSH=$HOME/.oh-my-zsh

# shellcheck disable=SC2016
export ROSCONSOLE_FORMAT='[${severity}] [${node}] [${time}]: ${message}'
