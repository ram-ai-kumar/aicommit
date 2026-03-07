#!/usr/bin/env bats
# Unit Tests — lib/core.sh (9 functions)

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# ─── get_aicommit_tmp_dir ────────────────────────────────────────────────────

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

@test "get_aicommit_tmp_dir sets directory permissions to 700" {
    local d perms
    d=$(get_aicommit_tmp_dir)
    perms=$(stat -f %A "$d" 2>/dev/null || stat -c %a "$d" 2>/dev/null)
    [ "$perms" = "700" ]
}

@test "get_aicommit_tmp_dir returns the same path on repeated calls" {
    local d1 d2
    d1=$(get_aicommit_tmp_dir)
    d2=$(get_aicommit_tmp_dir)
    [ "$d1" = "$d2" ]
}

# ─── build_file_context ──────────────────────────────────────────────────────

@test "build_file_context creates FILE_CONTEXT, CHANGE_STATS, FILE_COUNT" {
    echo "content" > app.js
    git add app.js
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)

    build_file_context "$staged" "$numstat"

    local d
    d=$(get_aicommit_tmp_dir)
    [ -f "${d}/FILE_CONTEXT" ]
    [ -f "${d}/CHANGE_STATS" ]
    [ -f "${d}/FILE_COUNT" ]
}

@test "build_file_context counts staged files correctly" {
    echo "a" > f1.js
    echo "b" > f2.py
    git add f1.js f2.py
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)

    build_file_context "$staged" "$numstat"

    local d count
    d=$(get_aicommit_tmp_dir)
    count=$(cat "${d}/FILE_COUNT")
    [ "$count" = "2" ]
}

@test "build_file_context excludes .env from CHANGE_STATS" {
    echo "SECRET=abc" > .env
    echo "content"   > app.js
    git add .env app.js
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)

    build_file_context "$staged" "$numstat"

    local d
    d=$(get_aicommit_tmp_dir)
    ! grep -qF ".env" "${d}/CHANGE_STATS"
}

@test "build_file_context classifies .js files as javascript/typescript" {
    echo "var x=1;" > app.js
    git add app.js
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)

    build_file_context "$staged" "$numstat"

    local d
    d=$(get_aicommit_tmp_dir)
    grep -q "javascript/typescript" "${d}/FILE_CONTEXT"
}

@test "build_file_context classifies .sh files as shell" {
    echo "echo hi" > run.sh
    git add run.sh
    local staged numstat
    staged=$(git diff --staged --name-only)
    numstat=$(git diff --staged --numstat)

    build_file_context "$staged" "$numstat"

    local d
    d=$(get_aicommit_tmp_dir)
    grep -q "shell" "${d}/FILE_CONTEXT"
}

# ─── filter_and_truncate_diff ────────────────────────────────────────────────

@test "filter_and_truncate_diff passes empty input without error" {
    local result
    result=$(printf '' | filter_and_truncate_diff)
    [ -z "$result" ]
}

@test "filter_and_truncate_diff excludes .env file diffs" {
    local result
    result=$(printf 'diff --git a/.env b/.env\n+SECRET_KEY=abc\n' \
             | filter_and_truncate_diff)
    ! echo "$result" | grep -qF "SECRET_KEY"
}

@test "filter_and_truncate_diff passes through source file diffs" {
    local result
    result=$(printf 'diff --git a/src/app.sh b/src/app.sh\n+echo hello\n' \
             | filter_and_truncate_diff)
    echo "$result" | grep -qF "echo hello"
}

@test "filter_and_truncate_diff excludes .lock file diffs" {
    local result
    result=$(printf 'diff --git a/package-lock.json b/package-lock.json\n+{"lockfileVersion":2}\n' \
             | filter_and_truncate_diff)
    ! echo "$result" | grep -qF "lockfileVersion"
}

@test "filter_and_truncate_diff caps markdown files at 20 lines" {
    # Build a diff with 30 content lines for a .md file
    local input
    input="diff --git a/README.md b/README.md"$'\n'
    for i in $(seq 1 30); do
        input="${input}+line ${i}"$'\n'
    done
    local result
    result=$(printf '%s' "$input" | filter_and_truncate_diff)
    local count
    count=$(echo "$result" | grep -c "^+line" || true)
    [ "$count" -le 20 ]
}

@test "filter_and_truncate_diff caps source files at 80 lines" {
    local input
    input="diff --git a/src/app.sh b/src/app.sh"$'\n'
    for i in $(seq 1 100); do
        input="${input}+line_${i}=true"$'\n'
    done
    local result
    result=$(printf '%s' "$input" | filter_and_truncate_diff)
    local count
    count=$(echo "$result" | grep -c "^+line_" || true)
    [ "$count" -le 80 ]
}

# ─── process_commit ──────────────────────────────────────────────────────────

@test "process_commit creates a git commit with the given message" {
    echo "content" > app.js
    git add app.js
    process_commit "feat: add app.js"
    local msg
    msg=$(git log --format="%s" -1)
    [ "$msg" = "feat: add app.js" ]
}

# ─── cleanup_aicommit_ephemeral ──────────────────────────────────────────────

@test "cleanup_aicommit_ephemeral removes CHANGES_CONTEXT" {
    local d
    d=$(get_aicommit_tmp_dir)
    touch "${d}/CHANGES_CONTEXT"
    cleanup_aicommit_ephemeral
    [ ! -f "${d}/CHANGES_CONTEXT" ]
}

@test "cleanup_aicommit_ephemeral removes FILE_CONTEXT" {
    local d
    d=$(get_aicommit_tmp_dir)
    touch "${d}/FILE_CONTEXT"
    cleanup_aicommit_ephemeral
    [ ! -f "${d}/FILE_CONTEXT" ]
}

@test "cleanup_aicommit_ephemeral removes FILE_COUNT" {
    local d
    d=$(get_aicommit_tmp_dir)
    touch "${d}/FILE_COUNT"
    cleanup_aicommit_ephemeral
    [ ! -f "${d}/FILE_COUNT" ]
}

@test "cleanup_aicommit_ephemeral preserves FULL_PROMPT" {
    local d
    d=$(get_aicommit_tmp_dir)
    touch "${d}/FULL_PROMPT" "${d}/CHANGES_CONTEXT"
    cleanup_aicommit_ephemeral
    [ -f "${d}/FULL_PROMPT" ]
}

# ─── cleanup_aicommit_all ────────────────────────────────────────────────────

@test "cleanup_aicommit_all removes FULL_PROMPT" {
    local d
    d=$(get_aicommit_tmp_dir)
    touch "${d}/FULL_PROMPT"
    cleanup_aicommit_all
    [ ! -f "${d}/FULL_PROMPT" ]
}

@test "cleanup_aicommit_all removes all ephemeral files" {
    local d
    d=$(get_aicommit_tmp_dir)
    touch "${d}/CHANGES_CONTEXT" "${d}/FILE_CONTEXT" "${d}/FILE_COUNT" "${d}/FULL_PROMPT"
    cleanup_aicommit_all
    [ ! -f "${d}/CHANGES_CONTEXT" ]
    [ ! -f "${d}/FILE_CONTEXT" ]
    [ ! -f "${d}/FULL_PROMPT" ]
}
