#!/usr/bin/env bats
# Smoke Tests — basic sanity checks in ideal conditions.

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── Loading ─────────────────────────────────────────────────────────────────

@test "aicommit.sh sources without error" {
    # setup already sourced it; verify the key entry-points exist as functions
    declare -f aicommit > /dev/null
    declare -f aic      > /dev/null
}

@test "all library functions are available after source" {
    declare -f validate_prerequisites     > /dev/null
    declare -f get_aicommit_tmp_dir       > /dev/null
    declare -f build_file_context         > /dev/null
    declare -f filter_and_truncate_diff   > /dev/null
    declare -f build_ai_context           > /dev/null
    declare -f generate_commit_message    > /dev/null
    declare -f process_commit             > /dev/null
    declare -f cleanup_aicommit_ephemeral > /dev/null
    declare -f cleanup_aicommit_all       > /dev/null
    declare -f display_setup_info         > /dev/null
    declare -f display_error              > /dev/null
    declare -f detect_project_type        > /dev/null
    declare -f categorize_staged_files    > /dev/null
    declare -f validate_backend_prerequisites > /dev/null
    declare -f invoke_llm                 > /dev/null
}

# ─── Configuration ───────────────────────────────────────────────────────────

@test "default AI_BACKEND is ollama" {
    [ "$AI_BACKEND" = "ollama" ]
}

@test "default AI_MODEL is qwen2.5-coder:latest" {
    [ "$AI_MODEL" = "qwen2.5-coder:latest" ]
}

@test "default AI_TIMEOUT is 120" {
    [ "$AI_TIMEOUT" = "120" ]
}

@test "AI_PROMPT_FILE points to an existing file" {
    [ -f "$AI_PROMPT_FILE" ]
}

@test "AICOMMIT_DIR is set and exists" {
    [ -n "$AICOMMIT_DIR" ]
    [ -d "$AICOMMIT_DIR" ]
}

# ─── Help ────────────────────────────────────────────────────────────────────

@test "aicommit --help exits 0" {
    run aicommit --help
    [ "$status" -eq 0 ]
}

@test "aicommit --help shows usage line" {
    run aicommit --help
    assert_output_contains "Usage: aicommit [OPTIONS]"
}

@test "aicommit --help documents --dry-run flag" {
    run aicommit --help
    assert_output_contains "--dry-run"
}

@test "aicommit --help documents --verbose flag" {
    run aicommit --help
    assert_output_contains "--verbose"
}

@test "aicommit -h is an alias for --help" {
    run aicommit -h
    [ "$status" -eq 0 ]
    assert_output_contains "Usage: aicommit [OPTIONS]"
}

# ─── Temp directory ──────────────────────────────────────────────────────────

@test "get_aicommit_tmp_dir creates the directory" {
    local d
    d=$(get_aicommit_tmp_dir)
    [ -d "$d" ]
}

@test "get_aicommit_tmp_dir returns a path under /tmp/.aicommit" {
    local d
    d=$(get_aicommit_tmp_dir)
    [[ "$d" == /tmp/.aicommit/* ]]
}
