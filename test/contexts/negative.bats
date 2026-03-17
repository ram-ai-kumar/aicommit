#!/usr/bin/env bats
# Negative Tests — failure paths and rejection of invalid input.

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── aicommit entry point ────────────────────────────────────────────────────

@test "aicommit --dry-run fails with no staged changes" {
    run aicommit --dry-run
    [ "$status" -eq 1 ]
    assert_output_contains "No staged changes"
}

@test "aicommit fails with an unknown option" {
    run aicommit --not-a-real-flag
    [ "$status" -eq 1 ]
}

@test "aicommit unknown option shows helpful message" {
    run aicommit --not-a-real-flag
    assert_output_contains "Unknown option"
}

# ─── aic entry point ─────────────────────────────────────────────────────────

@test "aic fails with no staged changes" {
    run aic
    [ "$status" -eq 1 ]
    assert_output_contains "No staged changes"
}

# ─── validate_backend_prerequisites ──────────────────────────────────────────

@test "validate_backend_prerequisites rejects unknown backend" {
    export AI_BACKEND="totally_bogus"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
}

@test "validate_backend_prerequisites rejects llamacpp (not implemented)" {
    export AI_BACKEND="llamacpp"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
}

@test "validate_backend_prerequisites rejects localai (not implemented)" {
    export AI_BACKEND="localai"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
}

# ─── generate_commit_message ─────────────────────────────────────────────────

@test "generate_commit_message --dry-run fails when CHANGES_CONTEXT is missing" {
    local d
    d=$(get_aicommit_tmp_dir)
    rm -f "${d}/CHANGES_CONTEXT"
    run generate_commit_message --dry-run
    [ "$status" -eq 1 ]
}

@test "generate_commit_message --dry-run fails when CHANGES_CONTEXT is empty" {
    local d
    d=$(get_aicommit_tmp_dir)
    : > "${d}/CHANGES_CONTEXT"   # create but empty
    run generate_commit_message --dry-run
    [ "$status" -eq 1 ]
}

# ─── build_ai_context ────────────────────────────────────────────────────────

@test "build_ai_context returns 1 when staged_files is empty" {
    run build_ai_context "" "" ""
    [ "$status" -eq 1 ]
}

@test "build_ai_context shows No staged files error" {
    run build_ai_context "" "" ""
    assert_output_contains "No staged files"
}

# ─── validate_ollama_prerequisites ───────────────────────────────────────────

@test "validate_ollama_prerequisites fails when pgrep finds no process" {
    mock_bin "pgrep" "exit 1"
    run validate_ollama_prerequisites "qwen2.5-coder:latest"
    [ "$status" -eq 1 ]
    assert_output_contains "not running"
}

@test "test_model_loadability with failing model" {
    mock_bin "ollama" "exit 1"
    run test_model_loadability "test-model"
    [ "$status" -eq 1 ]
}

@test "find_fallback_model returns 1 when no models available" {
    mock_bin "ollama" "echo 'NAME            ID              SIZE    MODIFIED'"
    run find_fallback_model "nonexistent-model"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "validate_ollama_prerequisites fails when model not found" {
    mock_bin "pgrep" "exit 0"
    mock_bin "ollama" "echo 'NAME            ID              SIZE    MODIFIED'
echo 'other-model:latest      abc123   2.3 GB  1 day ago'"
    run validate_ollama_prerequisites "missing-model"
    [ "$status" -eq 1 ]
    assert_output_contains "Model 'missing-model' not found"
}
