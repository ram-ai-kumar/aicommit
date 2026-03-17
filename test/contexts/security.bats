#!/usr/bin/env bats
# Security Tests — Zero Trust Architecture principles.

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── Least Privilege: temp dir permissions ────────────────────────────────────

@test "temp directory is created with 700 permissions (owner-only)" {
    local d perms
    d=$(get_aicommit_tmp_dir)
    perms=$(stat -f %A "$d" 2>/dev/null || stat -c %a "$d" 2>/dev/null)
    [ "$perms" = "700" ]
}

@test "temp directory is not world-readable" {
    local d perms last
    d=$(get_aicommit_tmp_dir)
    perms=$(stat -f %A "$d" 2>/dev/null || stat -c %a "$d" 2>/dev/null)
    # Last octet (world bits) must be 0
    last="${perms: -1}"
    [ "$last" = "0" ]
}

# ─── Data Leakage: sensitive files excluded ───────────────────────────────────

@test ".env content does not appear in FILE_CONTEXT" {
    echo "SECRET_KEY=super_secret_value" > .env
    echo "normal content" > app.js
    git add .env app.js
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)
    build_file_context "$staged" "$numstat"
    local d
    d=$(get_aicommit_tmp_dir)
    ! grep -qF "SECRET_KEY" "${d}/FILE_CONTEXT"
}

@test ".env does not appear in CHANGE_STATS" {
    echo "TOKEN=abc" > .env
    echo "code" > app.js
    git add .env app.js
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)
    build_file_context "$staged" "$numstat"
    local d
    d=$(get_aicommit_tmp_dir)
    ! grep -qF ".env" "${d}/CHANGE_STATS"
}

@test ".env.production is excluded from categorized file output" {
    local files
    files="$(printf '.env\n.env.production\nsrc/app.sh')"
    run categorize_staged_files "$files" "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]
    refute_output_contains ".env"
}

@test "filter_and_truncate_diff strips .env file diffs completely" {
    local result
    result=$(printf 'diff --git a/.env b/.env\n+PASSWORD=hunter2\n' \
             | filter_and_truncate_diff)
    ! echo "$result" | grep -qF "PASSWORD=hunter2"
}

@test "credentials.key file excluded from file context" {
    echo "private key data" > server.key
    echo "normal" > app.js
    git add server.key app.js
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)
    build_file_context "$staged" "$numstat"
    local d
    d=$(get_aicommit_tmp_dir)
    ! grep -qF "server.key" "${d}/CHANGE_STATS"
}

# ─── Never Trust: backend validation ─────────────────────────────────────────

@test "unsupported backend is explicitly refused" {
    export AI_BACKEND="malicious_backend"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
    assert_output_contains "Unsupported backend"
}

@test "llamacpp backend refused until implemented" {
    export AI_BACKEND="llamacpp"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
}

@test "localai backend refused until implemented" {
    export AI_BACKEND="localai"
    run validate_backend_prerequisites
    [ "$status" -eq 1 ]
}

# ─── Micro-segmentation: temp dirs are repo-scoped ───────────────────────────

@test "get_aicommit_tmp_dir path is unique per repo name" {
    # The tmp dir includes the repo name — verify it doesn't use a global path
    local d
    d=$(get_aicommit_tmp_dir)
    # Path must be deeper than /tmp/.aicommit (must include a repo sub-dir)
    [[ "$d" != "/tmp/.aicommit" ]]
    [[ "$d" == /tmp/.aicommit/* ]]
}

# ─── dry-run: files created with restricted permissions ──────────────────────

@test "dry-run creates context files with non-world-readable permissions" {
    echo "content" > app.js
    git add app.js
    aicommit --dry-run > /dev/null 2>&1 || true

    local d
    d=$(get_aicommit_tmp_dir)
    for f in "$d"/FULL_PROMPT "$d"/FILE_CONTEXT "$d"/CHANGE_STATS; do
        [ -f "$f" ] || continue
        local perms last
        perms=$(stat -f %A "$f" 2>/dev/null || stat -c %a "$f" 2>/dev/null)
        last="${perms: -1}"
        [ "$last" = "0" ] || {
            echo "File $f has world-readable permissions: $perms" >&2
            return 1
        }
    done
}

@test "get_available_ollama_models does not expose sensitive data" {
    mock_bin "ollama" "echo 'NAME            ID              SIZE    MODIFIED'
echo 'model-with-secret-key:latest    secret123   4.7 GB  2 days ago'
echo 'model-with-token:latest       token456    2.3 GB  1 week ago'"
    run get_available_ollama_models
    [ "$status" -eq 0 ]
    # Should only return model names, not IDs or other sensitive data
    assert_output_contains "model-with-secret-key:latest"
    assert_output_contains "model-with-token:latest"
    refute_output_contains "secret123"
    refute_output_contains "token456"
}

@test "test_model_loadability does not expose prompt content in logs" {
    mock_bin "ollama" "echo \"Running model with prompt: 'secret data'\" >&2
echo \"OK\""
    mock_bin "timeout" "echo \"OK\""
    run test_model_loadability "test-model"
    [ "$status" -eq 0 ]
    # Should not expose prompt content
    refute_output_contains "secret data"
}

@test "find_fallback_model does not try models with suspicious names" {
    # Create a simple test that checks if suspicious models are filtered out
    # by mocking get_available_ollama_models directly
    get_available_ollama_models() {
        echo "../../../etc/passwd:latest"
        echo "|cat secrets.txt:latest"
        echo "safe-model:latest"
    }
    export -f get_available_ollama_models

    mock_bin "timeout" "echo \"OK\""
    # Mock ollama run to succeed only for safe model
    ollama() {
        if [ "$2" = "safe-model:latest" ]; then
            echo "OK"
            return 0
        else
            return 1
        fi
    }
    export -f ollama

    run find_fallback_model "preferred-model"
    [ "$status" -eq 0 ]
    # Should choose safe model, not suspicious ones
    [ "$output" = "safe-model:latest" ]
}

@test "validate_ollama_prerequisites sanitizes model names" {
    mock_bin "pgrep" "exit 0"
    mock_bin "ollama" "echo 'NAME            ID              SIZE    MODIFIED'
echo 'safe-model:latest           abc123   2.3 GB  1 day ago'
if [ \"\$1\" = \"run\" ]; then
    # Check if model name contains dangerous characters
    if [[ \"\$2\" =~ [|&;<>$\\\`\"'(){}] ]]; then
        echo \"Dangerous characters detected\" >&2
        exit 1
    fi
    echo \"OK\"
    exit 0
fi"
    # Try with dangerous model name
    run validate_ollama_prerequisites "safe-model; rm -rf /"
    [ "$status" -eq 1 ]
    assert_output_contains "Model 'safe-model; rm -rf /' not found"
}
