#!/usr/bin/env bash
# aicommit — Core Logic
# Orchestrates context building, prompt assembly, and LLM commit generation.

# Validate prerequisites
validate_prerequisites() {
    if ! pgrep -f "ollama" > /dev/null; then
        display_error "Ollama is not running" "Start it with: ollama serve"
        return 1
    fi

    local model="${AI_MODEL:-qwen2.5-coder:latest}"
    if ! ollama list 2>/dev/null | grep -q "$model"; then
        display_error "Model '$model' not found" "Pull it with: ollama pull $model"
        return 1
    fi

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

    local file_context change_stats enhanced_context
    file_context=$(cat "${tmp_dir}/FILE_CONTEXT")
    change_stats=$(cat "${tmp_dir}/CHANGE_STATS")
    enhanced_context=$(build_enhanced_context "$staged_files" "$changes")

    # Filter lock file diffs, keep meaningful changes (up to 800 lines)
    local lock_file_patterns='\.lock$|lock\.json$|lock\.yaml$|lock\.toml$'
    local lock_files=""

    while IFS= read -r file; do
        if [ -n "$file" ] && echo "$file" | grep -qE "$lock_file_patterns"; then
            lock_files="${lock_files}${file}\n"
        fi
    done <<< "$staged_files"

    local changes_summary
    if [ -n "$lock_files" ]; then
        changes_summary=$(echo "$changes" | awk '
        /^diff --git/ {
            skip = 0
            file = $NF
            sub(/^b\//, "", file)
        }
        file ~ /\.lock$/ || file ~ /lock\.json$/ || file ~ /lock\.yaml$/ || file ~ /lock\.toml$/ {
            skip = 1
        }
        !skip { print }
        ' | head -800)
    else
        changes_summary=$(echo "$changes" | head -800)
    fi

    # Build lock file stats from numstat
    local lock_stat=""
    if [ -n "$lock_files" ]; then
        lock_stat=$(printf '%b' "$lock_files" | sed '/^$/d' | while IFS= read -r lf; do
            local stat_line
            stat_line=$(echo "$numstat_data" | awk -v f="$lf" '$3 == f {printf "%s | +%s -%s\n", $3, $1, $2}')
            [ -n "$stat_line" ] && echo "$stat_line"
        done)
    fi

    local repo_name
    repo_name="${_AICOMMIT_REPO_NAME:-unknown}"

    local changes_context="=== REPOSITORY ===
${repo_name}

=== STAGED FILES ===
${file_context}

=== CHANGE STATISTICS ===
${change_stats}

${enhanced_context}

=== CHANGES ===
${changes_summary}"

    if [ -n "$lock_stat" ]; then
        changes_context="${changes_context}

=== DEPENDENCY FILE CHANGES (stat only) ===
${lock_stat}"
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

    # Run ollama in background to allow timeout and elapsed-time display
    local response_file="${tmp_dir}/RESPONSE"
    local error_file="${tmp_dir}/OLLAMA_ERROR"
    ollama run "$model" < "$prompt_out" > "$response_file" 2> "$error_file" &
    local ollama_pid=$!

    local elapsed=0
    # Prioritize AI_TIMEOUT as per TODO, fallback to AICOMMIT_TIMEOUT
    local timeout_secs=${AI_TIMEOUT:-${AICOMMIT_TIMEOUT:-120}}
    printf "🧠 Generating commit message..." > /dev/tty
    while kill -0 "$ollama_pid" 2>/dev/null; do
        sleep 0.5
        elapsed=$((elapsed + 5)) # We add .5 seconds each time
        # Only print every second to reduce terminal noise
        if (( elapsed % 10 == 0 )); then
            printf "\r🧠 Generating commit message... (%ds)" "$((elapsed / 10))" > /dev/tty
        fi
        if [ "$elapsed" -ge $((timeout_secs * 10)) ]; then
            kill "$ollama_pid" 2>/dev/null
            wait "$ollama_pid" 2>/dev/null
            printf "\r\033[K" > /dev/tty
            display_error "Ollama timed out after ${timeout_secs}s" "Model may be slow — try: ollama run $model"
            return 1
        fi
    done
    wait "$ollama_pid"
    local exit_code=$?
    printf "\n" > /dev/tty

    if [ $exit_code -ne 0 ]; then
        display_error "Ollama generation failed (exit $exit_code)" "Check diagnostic log: $error_file"
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
          "${tmp_dir}/OLLAMA_ERROR" > /dev/null 2>&1
}

# Cleanup everything including the prompt
cleanup_aicommit_all() {
    cleanup_aicommit_ephemeral
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)
    rm -f "${tmp_dir}/FULL_PROMPT" > /dev/null 2>&1
}
