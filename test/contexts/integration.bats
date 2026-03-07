#!/usr/bin/env bats
# Integration Tests — end-to-end workflows.

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── Help ────────────────────────────────────────────────────────────────────

@test "aicommit --help completes successfully" {
    run aicommit --help
    [ "$status" -eq 0 ]
}

@test "aicommit -h is equivalent to --help" {
    run aicommit -h
    [ "$status" -eq 0 ]
    assert_output_contains "Usage: aicommit"
}

# ─── dry-run workflow ─────────────────────────────────────────────────────────

@test "dry-run exits 0 when files are staged" {
    echo "console.log('hello');" > app.js
    git add app.js
    run aicommit --dry-run
    [ "$status" -eq 0 ]
}

@test "dry-run shows Staged files summary" {
    echo "function test() {}" > app.js
    git add app.js
    run aicommit --dry-run
    assert_output_contains "Staged"
}

@test "dry-run shows Dry run message" {
    echo "content" > app.js
    git add app.js
    run aicommit --dry-run
    assert_output_contains "Dry run"
}

@test "dry-run shows Ollama running setup line" {
    echo "content" > app.js
    git add app.js
    run aicommit --dry-run
    assert_output_contains "Ollama running"
}

@test "dry-run creates FULL_PROMPT file" {
    echo "content" > app.js
    git add app.js
    run aicommit --dry-run
    local d
    d=$(get_aicommit_tmp_dir)
    [ -f "${d}/FULL_PROMPT" ]
}

@test "FULL_PROMPT is non-empty after dry-run" {
    echo "content" > app.js
    git add app.js
    run aicommit --dry-run
    [ "$status" -eq 0 ]
    local d
    d=$(get_aicommit_tmp_dir)
    [ -s "${d}/FULL_PROMPT" ]
}

# ─── verbose mode ─────────────────────────────────────────────────────────────

@test "dry-run --verbose shows temp dir path" {
    echo "content" > app.js
    git add app.js
    run aicommit --dry-run --verbose
    [ "$status" -eq 0 ]
    assert_output_contains "Temp dir"
}

@test "dry-run --verbose shows CHANGES_CONTEXT path" {
    echo "content" > app.js
    git add app.js
    run aicommit --dry-run --verbose
    assert_output_contains "CHANGES_CONTEXT"
}

# ─── failure modes ────────────────────────────────────────────────────────────

@test "aicommit fails cleanly with no staged changes" {
    run aicommit --dry-run
    [ "$status" -eq 1 ]
    assert_output_contains "No staged changes"
}

@test "aic fails cleanly with no staged changes" {
    run aic
    [ "$status" -eq 1 ]
    assert_output_contains "No staged changes"
}

@test "aicommit --regenerate fails when no cached prompt" {
    local d
    d=$(get_aicommit_tmp_dir)
    rm -f "${d}/FULL_PROMPT"
    run aicommit --regenerate
    [ "$status" -eq 1 ]
    assert_output_contains "No cached prompt"
}

# ─── multi-file staging ───────────────────────────────────────────────────────

@test "dry-run succeeds with multiple staged files" {
    echo "js code"     > app.js
    echo "python code" > app.py
    echo "shell code"  > run.sh
    git add app.js app.py run.sh
    run aicommit --dry-run
    [ "$status" -eq 0 ]
}

@test "dry-run file count reflects staged files" {
    echo "a" > f1.sh
    echo "b" > f2.sh
    git add f1.sh f2.sh
    run aicommit --dry-run
    assert_output_contains "2 files"
}

# ─── cleanup after dry-run ────────────────────────────────────────────────────

@test "ephemeral context files are removed after dry-run" {
    echo "content" > app.js
    git add app.js
    # Run in a subshell so the EXIT trap fires
    ( aicommit --dry-run > /dev/null 2>&1 ) || true
    local d
    d=$(get_aicommit_tmp_dir)
    [ ! -f "${d}/CHANGES_CONTEXT" ]
}
