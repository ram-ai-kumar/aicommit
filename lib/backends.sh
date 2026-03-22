#!/usr/bin/env bash
# LLM Backend Abstraction Layer
# Provides unified interface for different LLM backends

# Validate backend prerequisites and model availability
validate_backend_prerequisites() {
    local backend="${AI_BACKEND:-ollama}"
    local model="${AI_MODEL:-qwen2.5-coder:latest}"

    case "$backend" in
        ollama)
            validate_ollama_prerequisites "$model"
            ;;
        llamacpp)
            validate_llamacpp_prerequisites "$model"
            ;;
        localai)
            validate_localai_prerequisites "$model"
            ;;
        *)
            display_error "Unsupported backend: $backend" "Supported backends: ollama, llamacpp, localai"
            return 1
            ;;
    esac
}

# Invoke LLM with unified interface
# Args: model, prompt_file, response_file, error_file, timeout_secs
invoke_llm() {
    local model="$1"
    local prompt_file="$2"
    local response_file="$3"
    local error_file="$4"
    local timeout_secs="$5"

    local backend="${AI_BACKEND:-ollama}"

    case "$backend" in
        ollama)
            invoke_ollama "$model" "$prompt_file" "$response_file" "$error_file" "$timeout_secs"
            ;;
        llamacpp)
            invoke_llamacpp "$model" "$prompt_file" "$response_file" "$error_file" "$timeout_secs"
            ;;
        localai)
            invoke_localai "$model" "$prompt_file" "$response_file" "$error_file" "$timeout_secs"
            ;;
        *)
            display_error "Unsupported backend: $backend" "Supported backends: ollama, llamacpp, localai"
            return 1
            ;;
    esac
}

# Ollama backend implementation

# Get list of available Ollama models
get_available_ollama_models() {
    ollama list 2>/dev/null | awk 'NR>1 && NF>=2 {print $1}' || true
}

# Get list of already loaded Ollama models
get_loaded_ollama_models() {
    ollama ps 2>/dev/null | awk 'NR>1 && NF>=2 {print $1}' || true
}

# Test if a model can be loaded successfully
test_model_loadability() {
    local model="$1"
    local test_prompt="Say 'OK'"
    local timeout=30

    # Try to run the model with a simple test prompt
    if echo "$test_prompt" | timeout "$timeout" ollama run "$model" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Find a suitable fallback model for commit generation
find_fallback_model() {
    local preferred_model="$1"
    local default_models=(
        "qwen2.5-coder:latest"
        "qwen2.5:latest"
        "llama3.2:latest"
        "llama3.1:latest"
        "llama3:latest"
        "codellama:latest"
        "deepseek-coder:latest"
        "mistral:latest"
        "mixtral:latest"
    )

    # Security: Skip models with suspicious names
    local suspicious_pattern='(\.\./|\.\|.*[|&;<>$`'"'"'(){}].*|\|.*)'

    # Only try to use the preferred model if it's available
    if ollama list 2>/dev/null | grep -qF "$preferred_model"; then
        # Security check: skip suspicious model names
        if ! echo "$preferred_model" | grep -qE "$suspicious_pattern"; then
            if test_model_loadability "$preferred_model"; then
                echo "$preferred_model"
                return 0
            fi
        fi
    fi

    # Only try known default models, not arbitrary available models
    for model in "${default_models[@]}"; do
        if ollama list 2>/dev/null | grep -qF "$model" && [ "$model" != "$preferred_model" ]; then
            # Security check: skip suspicious model names
            if ! echo "$model" | grep -qE "$suspicious_pattern"; then
                if test_model_loadability "$model"; then
                    echo "$model"
                    return 0
                fi
            fi
        fi
    done

    return 1  # No suitable model found
}

validate_ollama_prerequisites() {
    local model="$1"
    local fallback_model=""

    if ! pgrep -f "ollama" > /dev/null; then
        display_error "Ollama is not running" "Start it with: ollama serve"
        return 1
    fi

    # Check if model exists in Ollama
    if ! ollama list 2>/dev/null | grep -qF "$model"; then
        display_error "Model '$model' not found" "Pull it with: ollama pull $model"
        return 1
    fi

    # Test if the preferred model can be loaded
    if ! test_model_loadability "$model"; then
        echo "⚠️  Preferred model '$model' cannot be loaded (insufficient memory or other issue)"

        # Try to find a fallback model
        fallback_model=$(find_fallback_model "$model")
        if [ $? -eq 0 ] && [ -n "$fallback_model" ]; then
            echo "🔄 Using fallback model: $fallback_model"
            export AI_MODEL="$fallback_model"
            return 0
        else
            display_error "No suitable model available" "" \
                "Preferred model '$model' failed to load (likely insufficient RAM)" \
                "and no other suitable models found." \
                "" \
                "💡 Suggestions:" \
                "1. Free up RAM and try again" \
                "2. Pull a smaller model: ollama pull llama3.2:3b" \
                "3. Check available models: ollama list"
            return 1
        fi
    fi

    return 0
}

invoke_ollama() {
    local model="$1"
    local prompt_file="$2"
    local response_file="$3"
    local error_file="$4"
    local timeout_secs="$5"

    # Use the current AI_MODEL (might be different from original if fallback was used)
    local current_model="${AI_MODEL:-$model}"

    # Run ollama in background to allow timeout and elapsed-time display
    ollama run "$current_model" < "$prompt_file" > "$response_file" 2> "$error_file" &
    local ollama_pid=$!

    local elapsed=0
    printf "🧠 Generating commit message using $current_model..." > /dev/tty
    while kill -0 "$ollama_pid" 2>/dev/null; do
        sleep 0.5
        elapsed=$((elapsed + 5)) # We add .5 seconds each time
        # Only print every second to reduce terminal noise
        if (( elapsed % 10 == 0 )); then
            printf "\r🧠 Generating commit message using $current_model... (%ds)" "$((elapsed / 10))" > /dev/tty
        fi
        if [ "$elapsed" -ge $((timeout_secs * 10)) ]; then
            kill "$ollama_pid" 2>/dev/null
            wait "$ollama_pid" 2>/dev/null
            printf "\r\033[K" > /dev/tty

            # Check if this might be a memory issue
            local error_content
            error_content=$(cat "$error_file" 2>/dev/null || echo "")
            if echo "$error_content" | grep -qi -E "(memory|gpu|cuda|out of memory|oom|cannot allocate|insufficient)"; then
                display_error "Ollama timed out after ${timeout_secs}s (likely insufficient memory)" \
                    "Model '$current_model' may be too large for available RAM/GPU" \
                    "" \
                    "💡 Try:" \
                    "1. Using a smaller model: export AI_MODEL=llama3.2:3b" \
                    "2. Free up system RAM and retry" \
                    "3. Check available models: ollama list"
            else
                display_error "Ollama timed out after ${timeout_secs}s" "Model may be slow — try: ollama run $current_model"
            fi
            return 1
        fi
    done
    wait "$ollama_pid"
    local exit_code=$?
    printf "\n" > /dev/tty

    if [ $exit_code -ne 0 ]; then
        local error_content
        error_content=$(cat "$error_file" 2>/dev/null || echo "")

        # Check for memory-related errors
        if echo "$error_content" | grep -qi -E "(memory|gpu|cuda|out of memory|oom|cannot allocate|insufficient)"; then
            display_error "Ollama generation failed (insufficient memory)" \
                "Model '$current_model' is too large for available RAM/GPU" \
                "" \
                "💡 Try a smaller model:" \
                "export AI_MODEL=llama3.2:3b && aicommit"
        else
            display_error "Ollama generation failed (exit $exit_code)" "Check diagnostic log: $error_file"
        fi
        return 1
    fi
}

# Llama.cpp backend implementation (placeholder)
validate_llamacpp_prerequisites() {
    local model="$1"

    display_error "Llama.cpp backend not yet implemented" "Use AI_BACKEND=ollama for now"
    return 1
}

invoke_llamacpp() {
    local model="$1"
    local prompt_file="$2"
    local response_file="$3"
    local error_file="$4"
    local timeout_secs="$5"

    display_error "Llama.cpp backend not yet implemented" "Use AI_BACKEND=ollama for now"
    return 1
}

# LocalAI backend implementation (placeholder)
validate_localai_prerequisites() {
    local model="$1"

    display_error "LocalAI backend not yet implemented" "Use AI_BACKEND=ollama for now"
    return 1
}

invoke_localai() {
    local model="$1"
    local prompt_file="$2"
    local response_file="$3"
    local error_file="$4"
    local timeout_secs="$5"

    display_error "LocalAI backend not yet implemented" "Use AI_BACKEND=ollama for now"
    return 1
}
