#!/usr/bin/env bash
# aicommit — Default Configuration
# User overrides via ~/.aicommitrc take precedence.

# LLM
# LLM model to use for commit message generation (must be available in Ollama)
AI_MODEL="${AI_MODEL:-qwen2.5-coder:latest}"

# Path to custom prompt template for commit message generation
# Override in ~/.aicommitrc: AI_PROMPT_FILE="$HOME/.aicommit/templates/custom-prompt.txt"
AI_PROMPT_FILE="${AI_PROMPT_FILE:-$AICOMMIT_DIR/templates/prompt.txt}"

# Timeout for LLM inference (seconds). Increase for large models or slow hardware.
# Override in ~/.aicommitrc: AI_TIMEOUT=240
AI_TIMEOUT="${AI_TIMEOUT:-120}"
