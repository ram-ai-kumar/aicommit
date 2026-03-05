#!/usr/bin/env bash
# aicommit — Context Analyzer
# Analyzes staged changes to provide structural hints for commit message generation.

# Detect project type from staged files and repo contents
detect_project_type() {
    local staged_files="$1"

    if [ -f "Gemfile" ] || echo "$staged_files" | grep -q "Gemfile"; then
        echo "rails/ruby"
    elif [ -f "package.json" ] || echo "$staged_files" | grep -q "package.json"; then
        echo "node/javascript"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || echo "$staged_files" | grep -qE "(requirements\.txt|pyproject\.toml|setup\.py)"; then
        echo "python"
    elif [ -f "go.mod" ] || echo "$staged_files" | grep -q "go.mod"; then
        echo "go"
    elif [ -f "Cargo.toml" ] || echo "$staged_files" | grep -q "Cargo.toml"; then
        echo "rust"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ] || echo "$staged_files" | grep -qE "(pom\.xml|build\.gradle)"; then
        echo "java"
    else
        echo "unknown"
    fi
}

# Analyze change concentration across directories
analyze_change_concentration() {
    local staged_files="$1"
    local total_files
    total_files=$(echo "$staged_files" | grep -c '.')

    if [ "$total_files" -eq 0 ]; then
        echo "|0|0"
        return
    fi

    local top_dir_info
    top_dir_info=$(echo "$staged_files" | while IFS= read -r f; do
        [ -n "$f" ] && dirname "$f"
    done | sort | uniq -c | sort -rn | head -1)

    local max_count max_dir concentration
    max_count=$(echo "$top_dir_info" | awk '{print $1}')
    max_dir=$(echo "$top_dir_info" | awk '{print $2}')
    concentration=$((max_count * 100 / total_files))

    echo "${max_dir}|${max_count}|${concentration}"
}

# Detect new vs modified files ratio
detect_new_files_ratio() {
    local staged_files="$1"
    local total_files
    total_files=$(echo "$staged_files" | grep -c '.')
    local new_files
    new_files=$(git diff --staged --diff-filter=A --name-only 2>/dev/null | wc -l | tr -d ' ')

    if [ "$total_files" -gt 0 ]; then
        local new_ratio=$((new_files * 100 / total_files))
        echo "${new_files}|${total_files}|${new_ratio}"
    else
        echo "0|0|0"
    fi
}

# Detect dependency/framework upgrade pattern
detect_upgrade_pattern() {
    local staged_files="$1"
    local has_lockfile=false has_dep_file=false has_config_changes=false has_migration=false

    while IFS= read -r file; do
        case "$file" in
            *.lock|*lock.json|*-lock.yaml)
                has_lockfile=true ;;
            Gemfile|package.json|requirements.txt|go.mod|Cargo.toml|pyproject.toml)
                has_dep_file=true ;;
            config/*|*.yml|*.yaml|*.toml|*.cfg)
                has_config_changes=true ;;
            db/migrate/*|migrations/*|alembic/*)
                has_migration=true ;;
        esac
    done <<< "$staged_files"

    if $has_dep_file && $has_lockfile; then
        echo "dependency_upgrade"
    elif $has_dep_file && $has_config_changes; then
        echo "framework_upgrade"
    elif $has_migration; then
        echo "migration"
    else
        echo "none"
    fi
}

# Build enhanced context string from analysis results
build_enhanced_context() {
    local staged_files="$1"
    local changes="$2"

    local project_type concentration_info focus_dir focus_count concentration
    project_type=$(detect_project_type "$staged_files")
    concentration_info=$(analyze_change_concentration "$staged_files")
    focus_dir=$(echo "$concentration_info" | cut -d'|' -f1)
    focus_count=$(echo "$concentration_info" | cut -d'|' -f2)
    concentration=$(echo "$concentration_info" | cut -d'|' -f3)

    local ratio_info new_files total_files new_ratio
    ratio_info=$(detect_new_files_ratio "$staged_files")
    new_files=$(echo "$ratio_info" | cut -d'|' -f1)
    total_files=$(echo "$ratio_info" | cut -d'|' -f2)
    new_ratio=$(echo "$ratio_info" | cut -d'|' -f3)

    local upgrade_pattern
    upgrade_pattern=$(detect_upgrade_pattern "$staged_files")

    local enhanced_context="=== ENHANCED CONTEXT ===
Project Type: $project_type
Focus Directory: $focus_dir ($focus_count files, $concentration% concentration)
New Files: $new_files/$total_files ($new_ratio% new)"

    if [ "$upgrade_pattern" != "none" ]; then
        enhanced_context="${enhanced_context}
Upgrade Pattern: $upgrade_pattern"
    fi

    echo "$enhanced_context"
}
