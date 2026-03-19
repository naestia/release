#!/usr/bin/env bash

setup_github_env() {
    export GITHUB_OUTPUT="$(mktemp)"
    export GITHUB_ENV="$(mktemp)"
    export GITHUB_REF_NAME="v1.2.3"
    export GITHUB_SHA="abc123def456abc123def456abc123def456abc1"
}

teardown_github_env() {
    rm -f "$GITHUB_OUTPUT" "$GITHUB_ENV"
}

get_output() {
    grep "^$1=" "$GITHUB_OUTPUT" | tail -1 | cut -d'=' -f2-
}

get_env() {
    grep "^$1=" "$GITHUB_ENV" | tail -1 | cut -d'=' -f2-
}