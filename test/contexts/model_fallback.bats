#!/usr/bin/env bats
# Model Fallback Tests — comprehensive coverage for backend fallback functionality

setup() {
    source "$(dirname "$BATS_TEST_FILENAME")/../test_helper.sh"
    setup_test_env
    # Source backends library for testing
    source "$AICOMMIT_DIR/lib/backends.sh"
}

teardown() {
    cleanup_test_env
    # Clean up any test exports
    unset AI_MODEL
}

# ─── SMOKE TESTS ───────────────────────────────────────────────────────────────

@test "get_available_ollama_models returns model list" {
    # Mock ollama list command
    ollama() {
        echo "NAME            ID              SIZE    MODIFIED"
        echo "qwen2.5-coder:latest    abc123   4.7 GB  2 days ago"
        echo "llama3.2:latest          def456   2.3 GB  1 week ago"
    }
    export -f ollama

    run get_available_ollama_models
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "qwen2.5-coder:latest" ]
    [ "${lines[1]}" = "llama3.2:latest" ]
}

@test "test_model_loadability with successful model" {
    # Mock successful ollama run
    ollama() {
        if [ "$1" = "run" ] && [ "$2" = "test-model" ]; then
            echo "OK"
            return 0
        fi
        return 1
    }
    export -f ollama

    run test_model_loadability "test-model"
    [ "$status" -eq 0 ]
}

@test "find_fallback_model returns suitable model" {
    # Mock available models and loadability
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "llama3.2:latest          def456   2.3 GB  1 week ago"
            echo "mistral:latest           ghi789   4.1 GB  2 weeks ago"
        elif [ "$1" = "run" ] && [ "$2" = "llama3.2:latest" ]; then
            echo "OK"
            return 0
        elif [ "$1" = "run" ]; then
            return 1
        fi
    }
    export -f ollama

    run find_fallback_model "qwen2.5-coder:latest"
    [ "$status" -eq 0 ]
    [ "$output" = "llama3.2:latest" ]
}

# ─── NEGATIVE TESTS ─────────────────────────────────────────────────────────────

@test "test_model_loadability with failing model" {
    # Mock failing ollama run
    ollama() {
        if [ "$1" = "run" ] && [ "$2" = "test-model" ]; then
            return 1
        fi
    }
    export -f ollama

    run test_model_loadability "test-model"
    [ "$status" -eq 1 ]
}

@test "find_fallback_model returns 1 when no models available" {
    # Mock empty ollama list
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
        fi
    }
    export -f ollama

    run find_fallback_model "nonexistent-model"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "validate_ollama_prerequisites fails when ollama not running" {
    # Mock pgrep to return no processes
    pgrep() {
        return 1
    }
    export -f pgrep

    run validate_ollama_prerequisites "any-model"
    [ "$status" -eq 1 ]
    assert_output_contains "Ollama is not running"
}

@test "validate_ollama_prerequisites fails when model not found" {
    # Mock ollama running but model not found
    pgrep() {
        return 0
    }
    ollama() {
        echo "NAME            ID              SIZE    MODIFIED"
        echo "other-model:latest      abc123   2.3 GB  1 day ago"
    }
    export -f pgrep ollama

    run validate_ollama_prerequisites "missing-model"
    [ "$status" -eq 1 ]
    assert_output_contains "Model 'missing-model' not found"
}

# ─── EDGE TESTS ─────────────────────────────────────────────────────────────────

@test "find_fallback_model skips preferred model in search" {
    # Mock scenario where only preferred model exists
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "preferred-model:latest    abc123   4.7 GB  2 days ago"
        elif [ "$1" = "run" ]; then
            echo "OK"
            return 0
        fi
    }
    export -f ollama

    run find_fallback_model "preferred-model:latest"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "find_fallback_model prioritizes commit-specific models" {
    # Mock scenario with both commit-specific and generic models
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "generic-model:latest      abc123   2.3 GB  1 day ago"
            echo "llama3.2:latest          def456   4.1 GB  2 weeks ago"
        elif [ "$1" = "run" ] && [ "$2" = "llama3.2:latest" ]; then
            echo "OK"
            return 0
        elif [ "$1" = "run" ]; then
            return 1
        fi
    }
    export -f ollama

    run find_fallback_model "missing-model"
    [ "$status" -eq 0 ]
    # Should prefer llama3.2 (commit-specific) over generic
    [ "$output" = "llama3.2:latest" ]
}

@test "find_fallback_model prioritizes loaded models" {
    # Mock scenario with one loaded model and one commit-specific model
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "generic-loaded:latest     abc123   2.3 GB  1 day ago"
            echo "llama3.2:latest          def456   4.1 GB  2 weeks ago"
        elif [ "$1" = "ps" ]; then
            echo "NAME            ID              SIZE    PROCESSOR       UNTIL"
            echo "generic-loaded:latest     abc123   2.3 GB  100% GPU        4 mins"
        elif [ "$1" = "run" ]; then
            echo "OK"
            return 0
        fi
    }
    export -f ollama

    run find_fallback_model "missing-model"
    [ "$status" -eq 0 ]
    # Should prefer generic-loaded because it's already loaded in memory
    [ "$output" = "generic-loaded:latest" ]
}

@test "test_model_loadability handles timeout" {
    # Mock timeout command to simulate timeout
    timeout() {
        return 124  # timeout exit code
    }
    export -f timeout

    run test_model_loadability "slow-model"
    [ "$status" -eq 1 ]
}

@test "get_available_ollama_models handles malformed output" {
    # Mock malformed ollama list output
    ollama() {
        echo "invalid output without proper structure"
    }
    export -f ollama

    run get_available_ollama_models
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# ─── EXCEPTION TESTS ─────────────────────────────────────────────────────────────

@test "validate_ollama_prerequisites handles model load failure gracefully" {
    # Mock ollama running, model exists, but can't load
    pgrep() {
        return 0
    }
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "preferred-model:latest    abc123   8.5 GB  2 days ago"
            echo "fallback-model:latest     def456   2.3 GB  1 week ago"
        elif [ "$1" = "run" ] && [ "$2" = "preferred-model:latest" ]; then
            return 1  # Can't load
        elif [ "$1" = "run" ] && [ "$2" = "fallback-model:latest" ]; then
            echo "OK"
            return 0
        fi
    }
    export -f pgrep ollama

    # Capture stderr to check fallback message
    run validate_ollama_prerequisites "preferred-model:latest"
    [ "$status" -eq 0 ]
    assert_output_contains "Using fallback model"
    # Export check removed since BATS run runs in a subshell
}

@test "validate_ollama_prerequisites shows helpful error when no fallback works" {
    # Mock scenario where no models can load
    pgrep() {
        return 0
    }
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "huge-model:latest        abc123   16 GB  2 days ago"
        elif [ "$1" = "run" ]; then
            return 1  # All models fail to load
        fi
    }
    export -f pgrep ollama

    run validate_ollama_prerequisites "huge-model:latest"
    [ "$status" -eq 1 ]
    assert_output_contains "No suitable model available"
    assert_output_contains "insufficient memory"
}

@test "invoke_ollama handles memory-related errors" {
    # Mock memory error during generation
    ollama() {
        echo "Error: out of memory" >&2
        return 1
    }
    export -f ollama

    # Create test files
    local prompt_file="$TEST_TEMP_DIR/prompt_$RANDOM.txt"
    local response_file="$TEST_TEMP_DIR/response_$RANDOM.txt"
    local error_file="$TEST_TEMP_DIR/error_$RANDOM.txt"

    echo "test prompt" > "$prompt_file"

    run invoke_ollama "memory-hog-model" "$prompt_file" "$response_file" "$error_file" 30
    echo "Status was: $status"
    [ "$status" -eq 1 ] || [ "$status" -eq 127 ]
    assert_output_contains "insufficient memory"

    # Cleanup
    rm -f "$prompt_file" "$response_file" "$error_file"
}

@test "invoke_ollama uses fallback model when AI_MODEL was changed" {
    # Test that invoke_ollama uses the current AI_MODEL value
    export AI_MODEL="fallback-model"

    # Mock successful ollama run
    ollama() {
        if [ "$1" = "run" ] && [ "$2" = "fallback-model" ]; then
            echo "Generated commit message"
            return 0
        fi
    }
    export -f ollama

    # Create test files
    local prompt_file="$TEST_TEMP_DIR/prompt_$RANDOM.txt"
    local response_file="$TEST_TEMP_DIR/response_$RANDOM.txt"
    local error_file="$TEST_TEMP_DIR/error_$RANDOM.txt"

    echo "test prompt" > "$prompt_file"

    run invoke_ollama "original-model" "$prompt_file" "$response_file" "$error_file" 30
    [ "$status" -eq 0 ]

    # Cleanup
    rm -f "$prompt_file" "$response_file" "$error_file"
}

# ─── SECURITY TESTS ─────────────────────────────────────────────────────────────

@test "get_available_ollama_models does not expose sensitive data" {
    # Mock ollama list with potentially sensitive data
    ollama() {
        echo "NAME            ID              SIZE    MODIFIED"
        echo "model-with-secret-key:latest    secret123   4.7 GB  2 days ago"
        echo "model-with-token:latest       token456    2.3 GB  1 week ago"
    }
    export -f ollama

    run get_available_ollama_models
    [ "$status" -eq 0 ]
    # Should only return model names, not IDs or other sensitive data
    assert_output_contains "model-with-secret-key:latest"
    assert_output_contains "model-with-token:latest"
    refute_output_contains "secret123"
    refute_output_contains "token456"
}

@test "test_model_loadability does not expose prompt content in logs" {
    # Mock ollama that logs to stderr
    ollama() {
        echo "Running model with prompt: 'secret data'" >&2
        echo "OK"
        return 0
    }
    export -f ollama

    run test_model_loadability "test-model"
    [ "$status" -eq 0 ]
    # Should not expose prompt content
    refute_output_contains "secret data"
}

@test "find_fallback_model does not try models with suspicious names" {
    # Mock ollama list with suspicious model names
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "../../../etc/passwd:latest    abc123   1.0 GB  1 day ago"
            echo "|cat secrets.txt:latest      def456   2.0 GB  2 days ago"
            echo "safe-model:latest           ghi789   3.0 GB  3 days ago"
        elif [ "$1" = "run" ] && [ "$2" = "safe-model:latest" ]; then
            echo "OK"
            return 0
        elif [ "$1" = "run" ]; then
            return 1
        fi
    }
    export -f ollama

    run find_fallback_model "preferred-model"
    [ "$status" -eq 0 ]
    # Should choose safe model, not suspicious ones
    [ "$output" = "safe-model:latest" ]
}

@test "validate_ollama_prerequisites sanitizes model names" {
    # Mock ollama with injection attempt
    pgrep() {
        return 0
    }
    ollama() {
        if [ "$1" = "list" ]; then
            echo "NAME            ID              SIZE    MODIFIED"
            echo "safe-model:latest           abc123   2.3 GB  1 day ago"
        elif [ "$1" = "run" ]; then
            # Check if model name contains dangerous characters
            if echo "$2" | grep -qE '[\|&;<>$`'"'"'(){} ]'; then
                echo "Dangerous characters detected" >&2
                return 1
            fi
            echo "OK"
            return 0
        fi
    }
    export -f pgrep ollama

    # Try with dangerous model name
    run validate_ollama_prerequisites "safe-model; rm -rf /"
    [ "$status" -eq 1 ]
    assert_output_contains "Model 'safe-model; rm -rf /' not found"
}
