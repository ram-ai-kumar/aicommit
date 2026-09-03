#!/usr/bin/env bash
# aicommit — Output Formatter
# Display helpers for commit messages, errors, and status.

display_setup_info() {
    local file_count="$1" file_list="$2"
    local staged_status=""

    if command -v git &>/dev/null; then
        staged_status=$(git status 2>/dev/null | awk '/Changes to be committed:/{flag=1; next} /^[A-Za-z]/{flag=0} flag' | grep -E '^\s*(modified|new file|deleted|renamed|typechange):' || true)
    fi

    echo "💡 Setup: Ollama running, model ready"
    if [ -n "$staged_status" ]; then
        echo "📁 Staged ($file_count files):"
        echo "$staged_status"
    elif [ -n "$file_list" ]; then
        echo "📁 Staged ($file_count files): $file_list"
    else
        echo "📁 Staged ($file_count files)"
    fi
}

display_commit_message() {
    local commit_msg="$1"

    echo ""
    echo "Suggested Commit:"
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "$commit_msg" | fold -w 63 | while IFS= read -r line; do
        printf "│ %-63s │\n" "$line"
    done
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
}

display_error() {
    local error_msg="$1" debug_info="$2"

    echo "❌ $error_msg" >&2
    [ -n "$debug_info" ] && echo "🔍 Debug: $debug_info" >&2
}

display_success() {
    echo "✅ Committed!"
}

display_commit_confirmation() {
    echo "Use this message? ([Y]/n/e to edit)"
}
