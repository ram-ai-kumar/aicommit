@functional @error-handling @stage2
Feature: AI Commit Advanced Error Handling
  As a developer using aicommit
  I want advanced error handling to work reliably under challenging conditions
  So I can trust that the system gracefully handles complex failure scenarios

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Network connectivity failures during AI communication
    Given ollama backend is configured
    And network connection is unstable
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then network failures should be detected
    And retry mechanisms should be attempted
    And graceful degradation should occur
    And user should be informed about network issues

  Scenario: AI service rate limiting handling
    Given ollama backend has rate limits
    And I have made multiple changes
    When I run aicommit command "--dry-run"
    Then rate limiting should be detected
    And backoff strategy should be applied
    And request should be retried after delay
    And user should be informed about rate limiting

  Scenario: Malformed response handling from AI service
    Given ollama backend returns malformed JSON
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then malformed response should be detected
    And error should be logged with details
    And fallback response should be attempted
    And user should receive clear error message

  Scenario: Concurrent access conflicts during processing
    Given multiple aicommit instances attempt to run
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then concurrent access should be detected
    And lock mechanism should prevent conflicts
    And operation should wait or fail gracefully
    And user should be informed about concurrent access

  Scenario: Resource exhaustion scenarios
    Given system has limited memory available
    And I have made large changes
    When I run aicommit command "--dry-run"
    Then memory constraints should be detected
    And processing should be optimized for low memory
    And large changes should be processed in chunks
    And user should be informed about resource limitations

  Scenario: File system permission edge cases
    Given files have complex permission structure
    And I have made changes to restricted files only
    When I run aicommit command "--dry-run"
    Then permission issues should be handled gracefully
    And accessible files should be processed
    And restricted files should be skipped with warning
    And user should be informed about permission issues

  Scenario: Graceful degradation testing
    Given ollama backend is partially available
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then partial functionality should be detected
    And available features should be used
    And unavailable features should be disabled
    And user should be informed about degraded mode

  Scenario: Database corruption handling
    Given aicommit cache is corrupted
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then corruption should be detected
    And cache should be rebuilt automatically
    And processing should continue with fresh cache
    And user should be informed about cache recovery

  Scenario: Temporary file system failures
    Given temporary directory cannot be created
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then filesystem failure should be detected
    And alternative temporary location should be attempted
    And operation should continue if possible
    And user should be informed about filesystem issues

  Scenario: AI model timeout during processing
    Given AI model takes too long to respond
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then timeout should be detected
    And operation should be cancelled gracefully
    And partial results should be discarded
    And user should be informed about timeout

  Scenario: Configuration corruption recovery
    Given configuration file is corrupted
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then configuration corruption should be detected
    And default configuration should be used
    And user should be informed about configuration issues
    And operation should continue with defaults

  Scenario: External dependency failures
    Given required external tools are unavailable
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then missing dependencies should be detected
    And alternative approaches should be attempted
    And functionality should be limited appropriately
    And user should be informed about missing dependencies

  Scenario: Reject unknown command line options
    When I run "aicommit --not-a-real-flag"
    Then the command should fail with exit code 1
    And output should contain "Unknown option"

  Scenario: Fail gracefully with no staged changes
    When I run "aicommit --dry-run"
    Then the command should fail with exit code 1
    And output should contain "No staged changes"

  Scenario: Fail gracefully with no staged changes using aic
    When I run "aic"
    Then the command should fail with exit code 1
    And output should contain "No staged changes"

  Scenario: Reject unsupported backend
    Given AI_BACKEND is set to "totally_bogus"
    When I validate backend prerequisites
    Then validation should fail
    And error should mention "Unsupported backend"

  Scenario: Reject unimplemented llamacpp backend
    Given AI_BACKEND is set to "llamacpp"
    When I validate backend prerequisites
    Then validation should fail
    And error should indicate backend is not implemented

  Scenario: Reject unimplemented localai backend
    Given AI_BACKEND is set to "localai"
    When I validate backend prerequisites
    Then validation should fail
    And error should indicate backend is not implemented

  Scenario: Fail when changes context is missing
    Given aicommit temporary directory exists
    But CHANGES_CONTEXT file is missing
    When I run "generate_commit_message --dry-run"
    Then the command should fail
    And error should indicate missing context

  Scenario: Fail when changes context is empty
    Given aicommit temporary directory exists
    And CHANGES_CONTEXT file exists but is empty
    When I run "generate_commit_message --dry-run"
    Then the command should fail
    And error should indicate empty context

  Scenario: Fail build_ai_context with no staged files
    When I build AI context with empty staged files
    Then the command should fail with exit code 1
    And output should contain "No staged files"

  Scenario: Fail ollama validation when process not running
    Given pgrep finds no ollama process
    When I validate ollama prerequisites for "qwen2.5-coder:latest"
    Then validation should fail
    And error should mention "not running"

  Scenario: Fail model loadability test with failing model
    Given ollama command fails for test model
    When I test model loadability for "test-model"
    Then the test should fail
    And exit code should be 1

  Scenario: Fail fallback model search when no models available
    Given ollama returns empty model list
    When I search for fallback model for "nonexistent-model"
    Then search should fail with exit code 1
    And output should be empty

  Scenario: Fail ollama validation when model not found
    Given ollama is running
    But model list does not contain "missing-model"
    When I validate ollama prerequisites for "missing-model"
    Then validation should fail
    And error should mention model not found

  Scenario: Reject dangerous model names
    Given ollama is running
    When I validate ollama prerequisites for "safe-model; rm -rf /"
    Then validation should fail
    And error should mention model not found

  Scenario: Handle malformed ollama output gracefully
    Given ollama returns malformed output
    When I list available models
    Then command should succeed
    And But output should be empty

  Scenario: Reject invalid timeout values
    Given AI_TIMEOUT is set to "invalid_number"
    When I validate configuration
    Then validation should fail
    And error should mention invalid timeout

  Scenario: Handle missing prompt file gracefully
    Given AI_PROMPT_FILE points to non-existent file
    When I validate configuration
    Then validation should fail
    And error should mention missing prompt file

  Scenario: Fail when git repository is not initialized
    Given current directory is not a git repository
    When I run "aicommit --dry-run"
    Then the command should fail
    And error should mention git repository

  Scenario: Fail when git is not available
    Given git command is not available
    When I validate prerequisites
    Then validation should fail
    And error should mention git installation

  Scenario: Handle permission denied on temporary directory
    Given temporary directory cannot be created due to permissions
    When I request aicommit temporary directory
    Then the operation should fail
    And error should mention permissions

  Scenario: Reject concurrent aicommit instances
    Given an aicommit instance is already running
    When I try to start another aicommit instance
    Then the second instance should fail
    And wait for the first to complete

  Scenario: Handle network timeouts gracefully
    Given ollama is running but responding slowly
    When I invoke ollama with timeout
    Then the operation should timeout gracefully
    And error should mention timeout

  Scenario: Validate input sanitization
    When I pass malicious input to aicommit
    Then the input should be sanitized
    And no command injection should occur
