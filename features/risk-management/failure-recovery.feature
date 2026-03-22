@functional
Feature: AI Commit Negative Tests
  As a developer using aicommit
  I want the system to properly handle invalid inputs and error conditions
  So I can trust that failures are handled gracefully

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

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
