#!/usr/bin/env bash
# aicommit — Default Configuration
# User overrides via ~/.aicommitrc take precedence.

# LLM
AI_MODEL="${AI_MODEL:-qwen2.5-coder:latest}"
AI_PROMPT_FILE="${AI_PROMPT_FILE:-$AICOMMIT_DIR/templates/prompt.txt}"
