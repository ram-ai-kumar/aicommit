#!/usr/bin/env bash
# aicommit installer — oh-my-zsh style
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/<user>/aicommit/main/install.sh)"
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

INSTALL_DIR="${AICOMMIT_DIR:-$HOME/.aicommit}"
REPO_URL="${AICOMMIT_REPO:-https://github.com/<user>/aicommit.git}"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source "$HOME/.aicommit/aicommit.sh"'

echo ""
echo "  ┌──────────────────────────────────────┐"
echo "  │        aicommit installer            │"
echo "  │  AI-powered conventional commits     │"
echo "  └──────────────────────────────────────┘"
echo ""

# ─── Prerequisites ────────────────────────────────────────────────────────────

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "${RED}Error:${RESET} $1 is required but not installed."
        [ -n "$2" ] && echo "  Install: $2"
        return 1
    fi
}

echo "Checking prerequisites..."
check_command git || exit 1
check_command ollama "https://ollama.ai/download" || exit 1
echo -e "  ${GREEN}✓${RESET} All prerequisites met"

# ─── Install ──────────────────────────────────────────────────────────────────

if [ -d "$INSTALL_DIR" ]; then
    echo ""
    echo -e "${YELLOW}aicommit is already installed at ${INSTALL_DIR}${RESET}"
    echo -n "  Reinstall? (y/n) "
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        echo "  Cancelled."
        exit 0
    fi
    echo "  Removing existing installation..."
    rm -rf "$INSTALL_DIR"
fi

echo ""
echo "Installing to $INSTALL_DIR..."
git clone --depth=1 "$REPO_URL" "$INSTALL_DIR" 2>/dev/null || {
    # Fallback: copy from local source if clone fails (for local dev)
    if [ -d "$(dirname "$0")" ]; then
        echo -e "  ${YELLOW}Git clone failed, copying from local source...${RESET}"
        mkdir -p "$INSTALL_DIR"
        cp -R "$(dirname "$0")"/* "$INSTALL_DIR"/
        cp -R "$(dirname "$0")"/.gitignore "$INSTALL_DIR"/ 2>/dev/null || true
    else
        echo -e "${RED}Error:${RESET} Failed to clone repository."
        exit 1
    fi
}

# Make bin scripts executable
chmod +x "$INSTALL_DIR/bin/aicommit" "$INSTALL_DIR/bin/aic" 2>/dev/null

echo -e "  ${GREEN}✓${RESET} Files installed"

# ─── Shell Integration ────────────────────────────────────────────────────────

if [ -f "$ZSHRC" ]; then
    if grep -qF "aicommit/aicommit.sh" "$ZSHRC"; then
        echo -e "  ${GREEN}✓${RESET} .zshrc already configured"
    else
        # Backup .zshrc
        cp "$ZSHRC" "${ZSHRC}.aicommit-backup"
        echo "" >> "$ZSHRC"
        echo "# aicommit — AI-powered conventional commits" >> "$ZSHRC"
        echo "$SOURCE_LINE" >> "$ZSHRC"
        echo -e "  ${GREEN}✓${RESET} Added source line to .zshrc (backup: .zshrc.aicommit-backup)"
    fi
else
    echo -e "  ${YELLOW}Warning:${RESET} ~/.zshrc not found. Add this line manually:"
    echo "  $SOURCE_LINE"
fi

# ─── Default Config ───────────────────────────────────────────────────────────

if [ ! -f "$HOME/.aicommitrc" ]; then
    cat > "$HOME/.aicommitrc" << 'EOF'
# aicommit configuration
# Uncomment and modify values to override defaults.

# LLM model (must be available in Ollama)
# AI_MODEL="qwen2.5-coder:latest"

# Custom prompt template (absolute path)
# AI_PROMPT_FILE="$HOME/.aicommit/templates/prompt.txt"
EOF
    echo -e "  ${GREEN}✓${RESET} Created ~/.aicommitrc (edit to customize)"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}aicommit installed successfully!${RESET}"
echo ""
echo "  Usage:"
echo "    aicommit          Interactive AI commit"
echo "    aic               Quick auto-commit"
echo "    aicommit --help   Show all options"
echo ""
echo "  Reload your shell to start using aicommit:"
echo "    exec zsh"
echo ""
