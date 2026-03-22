@ai-models @critical
Feature: AI Model Management Tests
  As a developer relying on AI for commit messages
  I want reliable model validation and basic fallback mechanisms
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

  Scenario: Basic fallback model selection from predefined list
    Given primary model is not available
    And default models are available
    When I search for fallback model
    Then a suitable fallback model should be selected from defaults
    And the fallback should be loadable
    And fallback should be from known safe models

  Scenario: Fallback model includes preferred model when available
    Given preferred model is available in model list
    When I search for fallback model
    Then preferred model should be returned
    And search should succeed

  Scenario: Fallback model handles malformed ollama output gracefully
    Given ollama returns invalid output structure
    When I list available models
    Then command should succeed
    But output should be empty
    And no errors should crash the system

  Scenario: Fallback model fails when no models available
    Given ollama returns empty model list
    When I search for fallback model
    Then search should fail with exit code 1
    And output should be empty
    And appropriate error should be displayed

  Scenario: Model validation with suspicious names
    Given available models include suspicious names
    When I search for fallback model
    Then models with path traversal should be rejected
    And models with command injection should be rejected
    And only safe models should be selected

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

  Scenario: LLM routing to unimplemented backends fails gracefully
    Given AI_BACKEND is set to "llamacpp"
    When I invoke LLM with test parameters
    Then the command should fail
    And error should mention "not yet implemented"

  Scenario: LLM routing to localai fails gracefully
    Given AI_BACKEND is set to "localai"
    When I invoke LLM with test parameters
    Then the command should fail
    And error should mention "not yet implemented"

  Scenario: Ollama validation fails when process not running
    Given pgrep finds no ollama process
    When I validate ollama prerequisites for "qwen2.5-coder:latest"
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
