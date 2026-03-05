# Bash completion for aicommit
_aicommit_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts="--help --dry-run --verbose --regenerate -h -d -v -r"
    COMPREPLY=($(compgen -W "$opts" -- "$cur"))
}

complete -F _aicommit_completions aicommit
