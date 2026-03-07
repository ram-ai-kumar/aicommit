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
