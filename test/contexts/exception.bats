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
    run validate_ollama_prerequisites "$(get_default_ai_model)"
    [ "$status" -eq 1 ]
}

@test "invoke_ollama handles memory-related errors" {
    mock_bin "ollama" "echo 'Error: out of memory' >&2
exit 1"

    # Create test files
    local prompt_file="$(mktemp)"
    local response_file="$(mktemp)"
    local error_file="$(mktemp)"

    echo "test prompt" > "$prompt_file"

    run invoke_ollama "memory-hog-model" "$prompt_file" "$response_file" "$error_file" 30
    [ "$status" -eq 1 ]
    assert_output_contains "insufficient memory"

    # Cleanup
    rm -f "$prompt_file" "$response_file" "$error_file"
}

@test "invoke_ollama respects configured AI_MODEL" {
    export AI_MODEL="configured-model"

    mock_bin "ollama" "if [ \"\$2\" = \"configured-model\" ]; then
    echo \"Generated commit message\"
    exit 0
else
    exit 1
fi"

    # Create test files
    local prompt_file="$TEST_TEMP_DIR/prompt_$RANDOM.txt"
    local response_file="$TEST_TEMP_DIR/response_$RANDOM.txt"
    local error_file="$TEST_TEMP_DIR/error_$RANDOM.txt"

    echo "test prompt" > "$prompt_file"

    run invoke_ollama "original-model" "$prompt_file" "$response_file" "$error_file" 30
    [ "$status" -eq 0 ]

    # Cleanup
    rm -f "$prompt_file" "$response_file" "$error_file"
    unset AI_MODEL
}
