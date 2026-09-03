@ai-models @critical
Feature: AI Model Management Tests
  As a developer relying on AI for commit messages
  I want reliable model validation and clear error handling
  So I can get commit messages with available models

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean
    And ollama is running

  Scenario: Basic model listing functionality
    When I list available models
    Then the command should succeed
    And model names should be returned
    And model IDs should not be exposed
    And sensitive data should not be exposed

  Scenario: Model loadability verification for working model
    Given a test model is available and functional
    When I test model loadability
    Then the test should pass
    And the model should respond correctly

  Scenario: Model loadability failure handling
    Given a model fails to load
    When I test model loadability
    Then the test should fail
    And appropriate error should be displayed

  Scenario: Handle malformed ollama output when listing models
    Given ollama returns invalid output structure
    When I list available models
    Then command should succeed
    But output should be empty
    And no errors should crash the system

  Scenario: Model validation sanitizes dangerous names
    Given model name contains dangerous characters
    When I validate ollama prerequisites
    Then dangerous characters should be detected
    And validation should fail
    And injection attempts should be blocked

  Scenario: Model validation handles memory errors gracefully
    Given ollama returns out of memory error
    When I invoke ollama for generation
    Then memory error should be handled gracefully
    And helpful error message should be displayed
    And user should be informed of memory constraints

  Scenario: Model validation respects AI_MODEL environment variable
    Given AI_MODEL is set to available model
    When I invoke ollama for generation
    Then environment variable should be respected
    And specified model should be used
    And generation should succeed

  Scenario: Model validation provides helpful error messages
    Given no suitable model is available
    When I validate ollama prerequisites
    Then clear error message should be displayed
    And pull instructions should be provided
    And alternative solutions should be suggested

  Scenario: Model validation handles service crashes
    Given ollama service crashes during validation
    When I validate ollama prerequisites
    Then service crash should be detected
    And appropriate error should be displayed
    And startup instructions should be provided

  Scenario: Backend validation rejects unknown backends
    Given AI_BACKEND is set to "nonexistent"
    When I validate backend prerequisites
    Then validation should fail
    And error should mention "Unsupported backend"
    And supported backends should be listed

  Scenario: Backend validation shows helpful error message
    Given AI_BACKEND is set to "bogus"
    When I validate backend prerequisites
    Then validation should fail
    And error should mention "Unsupported backend"

  Scenario: Ollama validation fails when process not running
    Given pgrep finds no ollama process
    When I validate ollama prerequisites for "qwen3.5-9b-unsloth:latest"
    Then validation should fail
    And error should mention "not running"
    And startup instructions should be provided

  Scenario: Ollama validation fails when model not found
    Given ollama is running
    But model list does not contain the requested model
    When I validate ollama prerequisites for "missing-model"
    Then validation should fail
    And error should mention model not found
    And pull instructions should be provided
