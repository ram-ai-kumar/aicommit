#!/usr/bin/env bats
# Unit Tests — lib/backends.sh (8 functions)

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── validate_backend_prerequisites ──────────────────────────────────────────

@test "validate_backend_prerequisites fails for unknown backend" {
    export AI_BACKEND="nonexistent"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
}

@test "validate_backend_prerequisites shows Unsupported backend message" {
    export AI_BACKEND="bogus"
    run validate_backend_prerequisites
    assert_output_contains "Unsupported backend"
}

# ─── invoke_llm routing ───────────────────────────────────────────────────────

@test "invoke_llm routes llamacpp to invoke_llamacpp (returns 1)" {
    export AI_BACKEND="llamacpp"
    run invoke_llm "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
    assert_output_contains "not yet implemented"
}

@test "invoke_llm routes localai to invoke_localai (returns 1)" {
    export AI_BACKEND="localai"
    run invoke_llm "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
    assert_output_contains "not yet implemented"
}

@test "invoke_llm with unknown backend returns 1" {
    export AI_BACKEND="unknown_llm"
    run invoke_llm "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
    assert_output_contains "Unsupported backend"
}

# ─── validate_ollama_prerequisites ───────────────────────────────────────────

@test "validate_ollama_prerequisites fails when ollama process not found" {
    # Mock pgrep to return no match (exit 1)
    mock_bin "pgrep" "exit 1"
    run validate_ollama_prerequisites "qwen2.5-coder:latest"
    [ "$status" -eq 1 ]
    assert_output_contains "not running"
}

@test "validate_ollama_prerequisites fails when model not in list" {
    # pgrep succeeds (ollama running), ollama list doesn't contain the model
    mock_bin "pgrep" "echo 12345; exit 0"
    mock_bin "ollama" "echo 'NAME  ID  SIZE'; exit 0"
    run validate_ollama_prerequisites "missing-model:latest"
    [ "$status" -eq 1 ]
    assert_output_contains "not found"
}

# ─── validate_llamacpp_prerequisites ─────────────────────────────────────────

@test "validate_llamacpp_prerequisites returns 1 (not yet implemented)" {
    run validate_llamacpp_prerequisites "any-model"
    [ "$status" -eq 1 ]
}

@test "validate_llamacpp_prerequisites explains it is not implemented" {
    run validate_llamacpp_prerequisites "any-model"
    assert_output_contains "not yet implemented"
}

# ─── validate_localai_prerequisites ──────────────────────────────────────────

@test "validate_localai_prerequisites returns 1 (not yet implemented)" {
    run validate_localai_prerequisites "any-model"
    [ "$status" -eq 1 ]
}

@test "validate_localai_prerequisites explains it is not implemented" {
    run validate_localai_prerequisites "any-model"
    assert_output_contains "not yet implemented"
}

# ─── invoke_llamacpp ─────────────────────────────────────────────────────────

@test "invoke_llamacpp returns 1 (not yet implemented)" {
    run invoke_llamacpp "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
}

@test "invoke_llamacpp explains it is not implemented" {
    run invoke_llamacpp "m" "/dev/null" "/dev/null" "/dev/null" "5"
    assert_output_contains "not yet implemented"
}

# ─── invoke_localai ──────────────────────────────────────────────────────────

@test "invoke_localai returns 1 (not yet implemented)" {
    run invoke_localai "m" "/dev/null" "/dev/null" "/dev/null" "5"
    [ "$status" -eq 1 ]
}

@test "invoke_localai explains it is not implemented" {
    run invoke_localai "m" "/dev/null" "/dev/null" "/dev/null" "5"
    assert_output_contains "not yet implemented"
}

# ─── invoke_ollama ────────────────────────────────────────────────────────────

@test "invoke_ollama returns 1 when ollama command fails" {
    mock_bin "ollama" "exit 1"
    local pf="$TEST_TEMP_DIR/prompt.txt"
    local rf="$TEST_TEMP_DIR/response.txt"
    local ef="$TEST_TEMP_DIR/error.txt"
    echo "test prompt" > "$pf"
    run invoke_ollama "test-model" "$pf" "$rf" "$ef" "5"
    [ "$status" -eq 1 ]
}
