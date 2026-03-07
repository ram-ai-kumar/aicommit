#!/usr/bin/env bash
# aicommit — AI-powered conventional commit message generator
# https://github.com/user/aicommit
#
# Sourced by .zshrc to provide `aicommit` and `aic` shell functions.
# Can also be sourced manually: source ~/.aicommit/aicommit.sh

# Resolve install directory
AICOMMIT_DIR="${AICOMMIT_DIR:-$HOME/.aicommit}"

# Load user config (overrides), then defaults (fills gaps)
[ -f "$HOME/.aicommitrc" ] && source "$HOME/.aicommitrc"
source "$AICOMMIT_DIR/config/defaults.sh"

# Source libraries
source "$AICOMMIT_DIR/lib/output-formatter.sh"
source "$AICOMMIT_DIR/lib/context-analyzer.sh"
source "$AICOMMIT_DIR/lib/backends.sh"
source "$AICOMMIT_DIR/lib/core.sh"

# Load completions
if [ -n "$ZSH_VERSION" ] && [ -d "$AICOMMIT_DIR/completions" ]; then
    fpath=("$AICOMMIT_DIR/completions" $fpath)
fi

# ─── Main Commands ────────────────────────────────────────────────────────────

# Interactive AI-powered conventional commit
aicommit() {
    local dry_run=false verbose=false regenerate=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                echo "Usage: aicommit [OPTIONS]"
                echo ""
                echo "AI-powered conventional commit message generator."
                echo "Analyzes staged changes and generates commit messages using local LLM."
                echo ""
                echo "Options:"
                echo "  --help, -h         Show this help message"
                echo "  --dry-run, -d      Build context and show prompt without calling LLM"
                echo "  --verbose, -v      Show temp file paths and enhanced context"
                echo "  --regenerate, -r   Re-run LLM on cached prompt without re-analyzing"
                echo ""
                echo "Examples:"
                echo "  git add -p && aicommit      Stage changes, then generate commit"
                echo "  aicommit --dry-run           Preview the prompt sent to LLM"
                echo "  aicommit --regenerate        Regenerate from last analysis"
                return 0
                ;;
            --dry-run|-d)    dry_run=true ;;
            --verbose|-v)    verbose=true ;;
            --regenerate|-r) regenerate=true ;;
            *) echo "Unknown option: $1. Use --help for usage."; return 1 ;;
        esac
        shift
    done

    export AICOMMIT_MODE=true
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)

    # Clean up ephemeral files on exit (keeps FULL_PROMPT if it exists)
    trap cleanup_aicommit_ephemeral EXIT

    # --regenerate: skip context building, re-run LLM on cached prompt
    if [ "$regenerate" = "true" ]; then
        if [ ! -f "${tmp_dir}/FULL_PROMPT" ]; then
            display_error "No cached prompt found in $tmp_dir" "Run aicommit first to build context"
            return 1
        fi
        if ! validate_prerequisites; then
            return 1
        fi
        echo "♻️  Regenerating from cached prompt..."
        [ "$verbose" = "true" ] && echo "📂 Prompt: ${tmp_dir}/FULL_PROMPT"

        local commit_msg
        commit_msg=$(generate_commit_message)
        if [ -z "$commit_msg" ]; then
            display_error "AI generated empty response" "check ${tmp_dir} for debug files"
            return 1
        fi
        display_commit_message "$commit_msg"
        display_commit_confirmation
        read -r response
        case $response in
            y|Y) process_commit "$commit_msg"; cleanup_aicommit_all; display_success ;;
            e|E) git commit -e -m "$commit_msg"; cleanup_aicommit_all ;;
            *)   echo "❌ Cancelled" ;;
        esac
        return 0
    fi

    # Capture staged changes (3 git calls total)
    local changes staged_files numstat_data
    changes=$(git diff --staged)
    staged_files=$(git diff --staged --name-only)
    numstat_data=$(git diff --staged --numstat)

    if [ -z "$changes" ] || [ -z "$staged_files" ]; then
        display_error "No staged changes"
        return 1
    fi

    # Validate prerequisites (skip for dry-run)
    if [ "$dry_run" != "true" ] && ! validate_prerequisites; then
        return 1
    fi

    # Build context first (this creates FILE_COUNT safely)
    build_ai_context "$changes" "$staged_files" "$numstat_data"
    if [ $? -ne 0 ]; then
        return 1
    fi

    local file_list file_count
    # Read count from temp file to avoid xtrace pollution in subshell capture
    file_count=$(cat "${tmp_dir}/FILE_COUNT" 2>/dev/null || echo "0")
    # Build list from staged_files safely
    file_list=$(printf '%s' "$staged_files" | tr '\n' ', ' | sed 's/,$//')

    display_setup_info "$file_count" "$file_list"
    if [ $? -ne 0 ]; then
        return 1
    fi

    if [ "$verbose" = "true" ]; then
        echo "📂 Temp dir: ${tmp_dir}"
        echo "   CHANGES_CONTEXT: ${tmp_dir}/CHANGES_CONTEXT"
        echo "   FULL_PROMPT:     ${tmp_dir}/FULL_PROMPT"
    fi

    # --dry-run: assemble prompt and exit
    if [ "$dry_run" = "true" ]; then
        generate_commit_message --dry-run > /dev/null 2>&1 || true
        echo ""
        echo "🔍 Dry run — prompt written to: ${tmp_dir}/FULL_PROMPT"
        echo "   cat ${tmp_dir}/FULL_PROMPT"
        return 0
    fi

    # Generate and display
    local commit_msg
    commit_msg=$(generate_commit_message)

    if [ -z "$commit_msg" ]; then
        display_error "AI generated empty response" "check ${tmp_dir} for debug files"
        return 1
    fi

    display_commit_message "$commit_msg"
    display_commit_confirmation
    read -r response

    case $response in
        y|Y) process_commit "$commit_msg"; cleanup_aicommit_all; display_success ;;
        e|E) git commit -e -m "$commit_msg"; cleanup_aicommit_all ;;
        *)   echo "❌ Cancelled" ;;
    esac
}

# Quick AI commit — auto-commits without confirmation
aic() {
    export AICOMMIT_MODE=true
    trap cleanup_aicommit_ephemeral EXIT

    local changes staged_files numstat_data
    changes=$(git diff --staged)
    staged_files=$(git diff --staged --name-only)
    numstat_data=$(git diff --staged --numstat)

    if [ -z "$changes" ] || [ -z "$staged_files" ]; then
        display_error "No staged changes"
        return 1
    fi

    if ! validate_prerequisites; then
        return 1
    fi

    # Build context first (this creates FILE_COUNT safely)
    build_ai_context "$changes" "$staged_files" "$numstat_data"
    if [ $? -ne 0 ]; then
        return 1
    fi

    local file_list file_count
    local tmp_dir
    tmp_dir=$(get_aicommit_tmp_dir)
    file_count=$(cat "${tmp_dir}/FILE_COUNT" 2>/dev/null || echo "0")
    file_list=$(printf '%s' "$staged_files" | tr '\n' ', ' | sed 's/,$//')
    display_setup_info "$file_count" "$file_list"
    if [ $? -ne 0 ]; then
        return 1
    fi

    local commit_msg
    commit_msg=$(generate_commit_message)

    if [ -z "$commit_msg" ]; then
        display_error "AI generated empty response" "check /tmp/.aicommit/ for debug files"
        return 1
    fi

    display_commit_message "$commit_msg"
    process_commit "$commit_msg"
    cleanup_aicommit_all
    display_success
}
