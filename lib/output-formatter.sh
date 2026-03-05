#!/usr/bin/env bash
# aicommit — Output Formatter
# Display helpers for commit messages, errors, and status.

display_setup_info() {
    local file_count="$1" file_list="$2"

    echo "💡 Setup: Ollama running, model ready"
    echo "📁 Staged ($file_count files): $file_list"
}

display_commit_message() {
    local commit_msg="$1"

    echo ""
    echo "🧠 Suggested Commit:"
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "$commit_msg" | fold -w 63 | while IFS= read -r line; do
        printf "│ %-63s │\n" "$line"
    done
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
}

display_error() {
    local error_msg="$1" debug_info="$2"

    echo "❌ $error_msg"
    [ -n "$debug_info" ] && echo "🔍 Debug: $debug_info"
}

display_success() {
    echo "✅ Committed!"
}

display_commit_confirmation() {
    echo "Use this message? (y/n/e for edit)"
}
