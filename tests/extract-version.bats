#!/usr/bin/env bats

load 'helpers/mock_github.sh'

SCRIPT="$BATS_TEST_DIRNAME/../scripts/extract-version.sh"

setup() {
    setup_github_env
}

teardown() {
    teardown_github_env
}

# ── Basic extraction ──────────────────────────────────────────────────────────

@test "extracts version by stripping v prefix" {
    export GITHUB_REF_NAME="v1.2.3"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output tag)" = "v1.2.3" ]
    [ "$(get_output version)" = "1.2.3" ]
    [ "$(get_output major)" = "v1" ]
}

@test "extracts version with no prefix" {
    export GITHUB_REF_NAME="1.2.3"
    export TAG_PREFIX=""

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output tag)" = "1.2.3" ]
    [ "$(get_output version)" = "1.2.3" ]
    [ "$(get_output major)" = "1" ]
}

@test "handles multi-digit version numbers" {
    export GITHUB_REF_NAME="v12.34.56"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output tag)" = "v12.34.56" ]
    [ "$(get_output version)" = "12.34.56" ]
    [ "$(get_output major)" = "v12" ]
}

@test "tag output matches GITHUB_REF_NAME exactly" {
    export GITHUB_REF_NAME="v0.1.0"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output tag)" = "$GITHUB_REF_NAME" ]
}

# ── Major tag output ──────────────────────────────────────────────────────────

@test "major tag uses only the major component" {
    export GITHUB_REF_NAME="v3.0.0"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output major)" = "v3" ]
}

@test "major tag preserves prefix" {
    export GITHUB_REF_NAME="v2.5.1"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output major)" = "v2" ]
}

@test "major tag with no prefix has no prefix" {
    export GITHUB_REF_NAME="2.5.1"
    export TAG_PREFIX=""

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output major)" = "2" ]
}

@test "major tag is correct for v0 releases" {
    export GITHUB_REF_NAME="v0.9.0"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output major)" = "v0" ]
}

# ── Patch / pre-release variants ──────────────────────────────────────────────

@test "handles patch-only bump correctly" {
    export GITHUB_REF_NAME="v1.2.4"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output version)" = "1.2.4" ]
    [ "$(get_output major)" = "v1" ]
}

@test "handles minor bump — major tag unchanged" {
    export GITHUB_REF_NAME="v1.3.0"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output version)" = "1.3.0" ]
    [ "$(get_output major)" = "v1" ]
}

@test "handles major bump — major tag advances" {
    export GITHUB_REF_NAME="v2.0.0"
    export TAG_PREFIX="v"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ "$(get_output version)" = "2.0.0" ]
    [ "$(get_output major)" = "v2" ]
}