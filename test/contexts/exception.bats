#!/usr/bin/env bats
# Exception Tests — error handling and graceful failure.

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── aicommit entry-point errors ─────────────────────────────────────────────

@test "aicommit exits 1 on no staged changes" {
    run aicommit --dry-run
    [ "$status" -eq 1 ]
}

@test "aicommit exits 1 on unknown flag" {
    run aicommit --this-flag-does-not-exist
    [ "$status" -eq 1 ]
}

@test "aicommit --regenerate exits 1 when no cached prompt exists" {
    local d
    d=$(get_aicommit_tmp_dir)
    rm -f "${d}/FULL_PROMPT"
    run aicommit --regenerate
    [ "$status" -eq 1 ]
    assert_output_contains "No cached prompt"
}

# ─── aic entry-point errors ───────────────────────────────────────────────────

@test "aic exits 1 on no staged changes" {
    run aic
    [ "$status" -eq 1 ]
}

# ─── generate_commit_message errors ──────────────────────────────────────────

@test "generate_commit_message returns 1 when CHANGES_CONTEXT is absent" {
    local d
    d=$(get_aicommit_tmp_dir)
    rm -f "${d}/CHANGES_CONTEXT"
    run generate_commit_message --dry-run
    [ "$status" -eq 1 ]
    assert_output_contains "Context files not found"
}

@test "generate_commit_message returns 1 when CHANGES_CONTEXT is empty" {
    local d
    d=$(get_aicommit_tmp_dir)
    : > "${d}/CHANGES_CONTEXT"
    run generate_commit_message --dry-run
    [ "$status" -eq 1 ]
}

# ─── build_ai_context errors ─────────────────────────────────────────────────

@test "build_ai_context returns 1 for empty staged files" {
    run build_ai_context "" "" ""
    [ "$status" -eq 1 ]
}

@test "build_ai_context shows No staged files error message" {
    run build_ai_context "" "" ""
    assert_output_contains "No staged files"
}

# ─── backend errors ───────────────────────────────────────────────────────────

@test "invoke_ollama returns 1 when the ollama binary fails" {
    mock_bin "ollama" "exit 1"
    local pf="$TEST_TEMP_DIR/prompt.txt"
    local rf="$TEST_TEMP_DIR/response.txt"
    local ef="$TEST_TEMP_DIR/error.txt"
    echo "prompt" > "$pf"
    run invoke_ollama "model" "$pf" "$rf" "$ef" "5"
    [ "$status" -eq 1 ]
}

@test "invoke_ollama shows generation failed message on error" {
    mock_bin "ollama" "exit 2"
    local pf="$TEST_TEMP_DIR/prompt.txt"
    local rf="$TEST_TEMP_DIR/response.txt"
    local ef="$TEST_TEMP_DIR/error.txt"
    echo "prompt" > "$pf"
    run invoke_ollama "model" "$pf" "$rf" "$ef" "5"
    assert_output_contains "generation failed"
}

@test "validate_ollama_prerequisites returns 1 when pgrep finds no process" {
    mock_bin "pgrep" "exit 1"
    run validate_ollama_prerequisites "qwen2.5-coder:latest"
    [ "$status" -eq 1 ]
}

@test "validate_llamacpp_prerequisites always returns 1" {
    run validate_llamacpp_prerequisites "any"
    [ "$status" -eq 1 ]
}

@test "validate_localai_prerequisites always returns 1" {
    run validate_localai_prerequisites "any"
    [ "$status" -eq 1 ]
}

@test "invoke_llamacpp always returns 1" {
    run invoke_llamacpp "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
}

@test "invoke_localai always returns 1" {
    run invoke_localai "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
}
