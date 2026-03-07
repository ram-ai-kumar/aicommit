#!/usr/bin/env bash
# aicommit — Core Logic
# Orchestrates context building, prompt assembly, and LLM commit generation.

# Validate prerequisites using backend abstraction
validate_prerequisites() {
    validate_backend_prerequisites
    return 0
}

# Get temp directory scoped to current repo
get_aicommit_tmp_dir() {
    # Cache repo root to avoid repeated git calls
    if [ -z "$_AICOMMIT_REPO_NAME" ]; then
        export _AICOMMIT_REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
    fi
    local tmp_dir="/tmp/.aicommit/${_AICOMMIT_REPO_NAME}"
    mkdir -m 700 -p "$tmp_dir" > /dev/null 2>&1
    echo "$tmp_dir"
}

# Build file context — writes FILE_CONTEXT, CHANGE_STATS, and FILE_COUNT to temp dir
# Args: $1=staged_files, $2=numstat_data
# Writes count to ${tmp_dir}/FILE_COUNT (avoids stdout pollution from zsh xtrace)
build_file_context() {
    local staged_files="$1"
    local numstat_data="$2"
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)

    # Restrict permissions for sensitive content
    umask 077

    # Zero-out owned files before writing — never use stale content
    : > "${tmp_dir}/FILE_CONTEXT"
    : > "${tmp_dir}/CHANGE_STATS"
    : > "${tmp_dir}/FILE_COUNT"

    local total_files=0
    local file_context=""
    local change_stats=""

    while IFS= read -r file; do
        # Use Bash internal trimming for significantly better performance than sed
        file="${file#"${file%%[![:space:]]*}"}"
        file="${file%"${file##*[![:space:]]}"}"
        # Remove carriage returns
        file="${file//$'\r'/}"
        [ -z "$file" ] && continue

        # Skip sensitive files from change statistics
        if echo "$file" | grep -qE "\.env$|\.env\.|config\.ini|.*secrets.*|.*credentials.*|.*\.key|.*\.pem|.*\.p12"; then
            total_files=$((total_files + 1))
            continue
        fi

        total_files=$((total_files + 1))

        local numstat_line lines_added lines_deleted file_ext file_type
        # Use grep for literal match to avoid awk field-splitting issues
        numstat_line=$(printf '%s\n' "$numstat_data" | grep -F $'\t'"${file}" | head -1)
        lines_added=$(printf '%s' "$numstat_line" | awk '{print $1}')
        lines_deleted=$(printf '%s' "$numstat_line" | awk '{print $2}')

        file_ext="${file##*.}"
        case "$file_ext" in
            js|ts|jsx|tsx) file_type="javascript/typescript" ;;
            py)            file_type="python" ;;
            sh|bash)       file_type="shell" ;;
            md|txt)        file_type="documentation" ;;
            json|yaml|yml) file_type="config" ;;
            html|css|scss) file_type="web" ;;
            rb)            file_type="ruby" ;;
            *)             file_type="$file_ext" ;;
        esac

        file_context="${file_context}
${file} (${file_type})"
        if [ -n "$lines_added" ] && [ -n "$lines_deleted" ]; then
            change_stats="${change_stats}
${file}: +${lines_added} -${lines_deleted} lines"
        fi
    done <<< "$staged_files"

    printf '%s' "$file_context" > "${tmp_dir}/FILE_CONTEXT"
    printf '%s' "$change_stats" > "${tmp_dir}/CHANGE_STATS"
    # Write count to file — avoids stdout pollution from zsh xtrace in subshell capture
    printf '%s' "$total_files" > "${tmp_dir}/FILE_COUNT"
}

# Filter diff by tier and truncate per-file. Reads from stdin, writes to stdout.
# Tier 1 (stat only)  — generated/binary/sensitive files: diff entirely excluded
# Tier 2 (20-line cap) — low-signal files: tests, docs, markdown
# Tier 3 (80-line cap) — full-signal files: source, config, migrations
filter_and_truncate_diff() {
    local sensitive_pattern='\.env$|\.env\.|config\.ini|.*secrets.*|.*credentials.*|.*\.key|.*\.pem|.*\.p12'

    awk -v sensitive="$sensitive_pattern" '
    BEGIN { tier = 3; max_lines = 80; file_lines = 0 }
    /^diff --git/ {
        if (file_lines > max_lines && max_lines > 0)
            printf "    ... (%d lines truncated)\n", (file_lines - max_lines)
        file = $NF; sub(/^b\//, "", file)
        file_lines = 0

        # Skip sensitive files entirely
        if (file ~ sensitive) {
            tier = 1; max_lines = 0
        }
        # Tier 1 — stat only
        if (file ~ /\.(lock|snap|pyc|class|map)$/ ||
            file ~ /lock\.(json|yaml|toml)$/ ||
            file ~ /\.(svg|png|jpg|jpeg|gif|ico|fig|webp|mp4|mp3|woff2?|ttf)$/ ||
            file ~ /\.min\.(js|css)$/ ||
            file ~ /_pb2\.py$/ || file ~ /\.pb\.go$/ ||
            file ~ /^dist\// || file ~ /\/dist\// ||
            file ~ /^build\// || file ~ /\/build\// ||
            file ~ /^out\// || file ~ /\/out\// ||
            file ~ /^\.next\// ||
            file ~ /^coverage\// || file ~ /\/coverage\// ||
            file ~ /^\.nyc_output\// ||
            file ~ /\.env$/ || file ~ /\.env\./) {
            tier = 1; max_lines = 0
        }
        # Tier 2 — low-signal, 20-line cap
        else if (file ~ /^tests?\// || file ~ /\/tests?\// ||
                 file ~ /^spec\// || file ~ /\/spec\// ||
                 file ~ /^__tests__\// ||
                 file ~ /\.(test|spec)\.(js|ts)$/ ||
                 file ~ /test_.*\.py$/ ||
                 file ~ /_test\.(py|go)$/ ||
                 file ~ /^docs?\// || file ~ /\/docs?\// ||
                 file ~ /\.(md|rst)$/ ||
                 file ~ /^README/ || file ~ /^CHANGELOG/ || file ~ /^CONTRIBUTING/) {
            tier = 2; max_lines = 20
        }
        # Tier 3 — full signal, 80-line cap
        else {
            tier = 3; max_lines = 80
        }
        if (tier >= 2) print
        next
    }
    {
        file_lines++
        if (tier >= 2 && file_lines <= max_lines) print
    }
    END {
        if (file_lines > max_lines && max_lines > 0)
            printf "    ... (%d lines truncated)\n", (file_lines - max_lines)
    }
    '
}

# Build AI context — writes CHANGES_CONTEXT to temp dir
# Args: $1=diff, $2=staged_files, $3=numstat_data
build_ai_context() {
    local changes="$1"
    local staged_files="$2"
    local numstat_data="$3"
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)

    # Restrict permissions for sensitive content
    umask 077

    # Zero-out owned file before writing — never use stale content
    : > "${tmp_dir}/CHANGES_CONTEXT"

    # Run build_file_context; read count from temp file to avoid xtrace stdout pollution
    build_file_context "$staged_files" "$numstat_data" > /dev/null 2>&1
    local total_files
    tmp_dir=$(get_aicommit_tmp_dir)
    total_files=$(cat "${tmp_dir}/FILE_COUNT" 2>/dev/null || echo "0")

    if [ "$total_files" -eq 0 ] 2>/dev/null || ! [ "$total_files" -gt 0 ] 2>/dev/null; then
        display_error "No staged files found"
        return 1
    fi

    # Filter out sensitive files from staged_files before processing
    local filtered_staged_files=""
    while IFS= read -r file; do
        if ! echo "$file" | grep -qE "\.env$|\.env\.|config\.ini|.*secrets.*|.*credentials.*|.*\.key|.*\.pem|.*\.p12"; then
            filtered_staged_files="${filtered_staged_files}${file}\n"
        fi
    done <<< "$staged_files"

    local file_context change_stats enhanced_context categories_context
    file_context=$(cat "${tmp_dir}/FILE_CONTEXT")
    change_stats=$(cat "${tmp_dir}/CHANGE_STATS")
    enhanced_context=$(build_enhanced_context "$filtered_staged_files" "$changes")
    categories_context=$(categorize_staged_files "$filtered_staged_files" "$tmp_dir")

    # Tier 1 patterns (stat only): generated, binary, sensitive — matches filter_and_truncate_diff tier 1
    local stat_only_ext='\.lock$|lock\.(json|yaml|toml)$|\.snap$|\.pyc$|\.class$|\.map$|_pb2\.py$|\.pb\.go$'
    local stat_only_assets='\.svg$|\.png$|\.jpg$|\.jpeg$|\.gif$|\.ico$|\.fig$|\.webp$|\.mp4$|\.mp3$|\.woff2?$|\.ttf$|\.min\.(js|css)$'
    local stat_only_dirs='^(dist|build|out|\.next|coverage|\.nyc_output)/|/(dist|build|coverage)/'
    local stat_only_env='\.env$|\.env\.|config\.ini|.*secrets.*|.*credentials.*|.*\.key|.*\.pem|.*\.p12'
    local stat_only_patterns="${stat_only_ext}|${stat_only_assets}|${stat_only_env}"
    local stat_only_files=""

    while IFS= read -r file; do
        if [ -n "$file" ] && { echo "$file" | grep -qE "$stat_only_patterns" || echo "$file" | grep -qE "$stat_only_dirs"; }; then
            stat_only_files="${stat_only_files}${file}\n"
        fi
    done <<< "$staged_files"

    # Single-pass tiered filter: excludes tier-1 diffs, caps tier-2 at 20 lines, tier-3 at 80 lines
    local changes_summary
    changes_summary=$(echo "$changes" | filter_and_truncate_diff)

    # Stat summary for tier-1 files (lets LLM infer dependency/asset changes without reading diff)
    local stat_only_stat=""
    if [ -n "$stat_only_files" ]; then
        stat_only_stat=$(printf '%b' "$stat_only_files" | sed '/^$/d' | while IFS= read -r sf; do
            local stat_line
            stat_line=$(echo "$numstat_data" | awk -v f="$sf" '$3 == f {printf "%s | +%s -%s\n", $3, $1, $2}')
            [ -n "$stat_line" ] && echo "$stat_line"
        done)
    fi

    local repo_name
    repo_name="${_AICOMMIT_REPO_NAME:-unknown}"

    local changes_context="=== REPOSITORY ===
${repo_name}

${categories_context}

=== CHANGE STATISTICS ===
${change_stats}

${enhanced_context}

=== CHANGES ===
${changes_summary}"

    if [ -n "$stat_only_stat" ]; then
        changes_context="${changes_context}

=== OMITTED DIFFS — stat only (generated/binary/sensitive) ===
${stat_only_stat}"
    fi

    # Add recent commit history for scope consistency
    local commit_history
    commit_history=$(git log --oneline -10 2>/dev/null)
    if [ -n "$commit_history" ]; then
        changes_context="${changes_context}

=== RECENT COMMITS (for scope consistency) ===
${commit_history}"
    fi

    printf '%s' "$changes_context" > "${tmp_dir}/CHANGES_CONTEXT"
}

# Generate commit message — assembles prompt and calls Ollama
# Args: --dry-run (optional)
generate_commit_message() {
    local dry_run=false
    [ "$1" = "--dry-run" ] && dry_run=true

    local model="${AI_MODEL:-qwen2.5-coder:latest}"
    local prompt_file="${AI_PROMPT_FILE}"
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)

    # Restrict permissions for sensitive content
    umask 077

    local changes_file="${tmp_dir}/CHANGES_CONTEXT"
    local prompt_out="${tmp_dir}/FULL_PROMPT"

    # Zero-out owned files before writing — never use stale content
    : > "${tmp_dir}/FULL_PROMPT"
    : > "${tmp_dir}/RESPONSE"
    : > "${tmp_dir}/OLLAMA_ERROR"

    if [ ! -f "$changes_file" ] || [ ! -s "$changes_file" ]; then
        display_error "Context files not found or empty in $tmp_dir"
        return 1
    fi

    # Assemble prompt: substitute template placeholders with context files
    awk '
    /\$\{CHANGES_CONTEXT\}/ {
        while ((getline line < changes_file) > 0) print line
        close(changes_file)
        next
    }
    { print }
    ' changes_file="$changes_file" "$prompt_file" > "$prompt_out"

    if [ "$dry_run" = "true" ]; then
        return 0
    fi

    # Invoke LLM using backend abstraction
    local response_file="${tmp_dir}/RESPONSE"
    local error_file="${tmp_dir}/OLLAMA_ERROR"
    local timeout_secs=${AI_TIMEOUT:-120}

    if ! invoke_llm "$model" "$prompt_out" "$response_file" "$error_file" "$timeout_secs"; then
        return 1
    fi

    local commit_msg
    commit_msg=$(cat "$response_file" 2>/dev/null)

    # Extract message from @@@ delimiters
    local extracted
    extracted=$(echo "$commit_msg" | sed -n '/^@@@$/,/^@@@$/{ /^@@@$/d; p; }')

    if [ -n "$extracted" ]; then
        commit_msg="$extracted"
    else
        # Fallback: strip common LLM preamble
        commit_msg=$(echo "$commit_msg" | sed '/^$/d; s/\*\*//g' | sed '
            /^[Hh]ere/d
            /^[Ss]ure/d
            /^[Bb]ased on/d
            /^[Cc]ertainly/d
            /^```/d
        ')
    fi

    # Post-processing: strictly enforce plain text by stripping markdown symbols
    # 1. Remove backticks (`)
    # 2. Remove double asterisks (**) for bold
    # 3. Remove single asterisks (*) or underscores (_) for italics (caution: might affect bullet points)
    # We strip backticks and bolding specifically as they are most common formatting LLMs use for paths/variables.
    commit_msg=$(echo "$commit_msg" | sed 's/`//g; s/\*\*//g')

    echo "$commit_msg"
}

# Execute the git commit
# Args: $1=commit_msg
process_commit() {
    local commit_msg="$1"
    echo "$commit_msg" | git commit -F -
}

# Cleanup ephemeral context files (keeps FULL_PROMPT for --regenerate)
cleanup_aicommit_ephemeral() {
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)
    rm -f "${tmp_dir}/CHANGES_CONTEXT" \
          "${tmp_dir}/FILE_CONTEXT" \
          "${tmp_dir}/CHANGE_STATS" \
          "${tmp_dir}/RESPONSE" \
          "${tmp_dir}/FILE_COUNT" \
          "${tmp_dir}/ASSET_FILES" \
          "${tmp_dir}/OLLAMA_ERROR" > /dev/null 2>&1
}

# Cleanup everything including the prompt
cleanup_aicommit_all() {
    cleanup_aicommit_ephemeral
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)
    rm -f "${tmp_dir}/FULL_PROMPT" > /dev/null 2>&1
}
