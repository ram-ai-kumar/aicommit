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
validate_ollama_prerequisites() {
    local model="$1"
    
    if ! pgrep -f "ollama" > /dev/null; then
        display_error "Ollama is not running" "Start it with: ollama serve"
        return 1
    fi
    
    if ! ollama list 2>/dev/null | grep -qF "$model"; then
        display_error "Model '$model' not found" "Pull it with: ollama pull $model"
        return 1
    fi
}

invoke_ollama() {
    local model="$1"
    local prompt_file="$2"
    local response_file="$3"
    local error_file="$4"
    local timeout_secs="$5"
    
    # Run ollama in background to allow timeout and elapsed-time display
    ollama run "$model" < "$prompt_file" > "$response_file" 2> "$error_file" &
    local ollama_pid=$!
    
    local elapsed=0
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
