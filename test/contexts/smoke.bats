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
    declare -f get_available_ollama_models > /dev/null
    declare -f test_model_loadability     > /dev/null
    declare -f find_fallback_model        > /dev/null
    declare -f validate_ollama_prerequisites > /dev/null
    declare -f invoke_ollama              > /dev/null
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

@test "get_available_ollama_models returns model list" {
    mock_bin "ollama" "echo 'NAME            ID              SIZE    MODIFIED'
echo 'qwen2.5-coder:latest    abc123   4.7 GB  2 days ago'
echo 'llama3.2:latest          def456   2.3 GB  1 week ago'"
    run get_available_ollama_models
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "qwen2.5-coder:latest" ]
    [ "${lines[1]}" = "llama3.2:latest" ]
}

@test "test_model_loadability with successful model" {
    mock_bin "ollama" "echo \"OK\""
    mock_bin "timeout" "echo \"OK\""
    run test_model_loadability "test-model"
    [ "$status" -eq 0 ]
}

@test "find_fallback_model returns suitable model" {
    mock_bin "ollama" "echo 'NAME            ID              SIZE    MODIFIED'
echo 'llama3.2:latest          def456   2.3 GB  1 week ago'
echo 'mistral:latest           ghi789   4.1 GB  2 weeks ago'
if [ \"\$2\" = \"llama3.2:latest\" ]; then
    echo \"OK\"
    exit 0
elif [ \"\$1\" = \"run\" ]; then
    exit 1
fi"
    mock_bin "timeout" "echo \"OK\""
    run find_fallback_model "qwen2.5-coder:latest"
    [ "$status" -eq 0 ]
    [ "$output" = "llama3.2:latest" ]
}
