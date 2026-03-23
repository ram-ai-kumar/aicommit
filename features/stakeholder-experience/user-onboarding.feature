@functional @smoke
Feature: AI Commit Smoke Tests
  As a developer using aicommit
  I want basic functionality to work in ideal conditions
  So I can rely on the tool for daily commit message generation

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Basic application loading
    When I source the aicommit script
    Then the main functions should be available
    And aicommit command should be defined
    And aic command should be defined

  Scenario: Default configuration validation
    When I check the default configuration
    Then AI_BACKEND should be "ollama"
    And AI_MODEL should be "qwen2.5-coder:latest"
    And AI_TIMEOUT should be "120"
    And AI_PROMPT_FILE should exist

  Scenario: Help system functionality
    When I run "aicommit --help"
    Then the command should exit successfully
    And output should contain "USAGE:"
    And output should contain "aicommit [ref]"
    And output should contain "--dry"

  Scenario: Help system short flag
    When I run "aicommit -h"
    Then the command should exit successfully
    And output should contain "USAGE:"

  Scenario: Temporary directory management
    When I request aicommit temporary directory
    Then the directory should be created
    And the directory should be under "/tmp/.aicommit"
    And the directory should have appropriate permissions

  Scenario: Ollama model listing
    Given ollama is available and running
    When I list available models
    Then I should see model names only
    And model IDs should not be exposed
    And the command should succeed

  Scenario: Model loadability verification
    Given ollama is available and running
    And a test model is available
    When I test model loadability
    Then the test should pass
    And the model should respond correctly

  Scenario: Fallback model selection
    Given ollama is available and running
    And multiple models are available
    When primary model is not available
    Then a suitable fallback model should be selected
    And the fallback should be loadable

  Scenario: Library functions availability
    When I source the aicommit script
    Then validate_prerequisites function should be available
    And get_aicommit_tmp_dir function should be available
    And build_file_context function should be available
    And filter_and_truncate_diff function should be available
    And build_ai_context function should be available
    And generate_commit_message function should be available
    And process_commit function should be available
    And cleanup_aicommit_ephemeral function should be available
    And cleanup_aicommit_all function should be available
    And display_setup_info function should be available
    And display_error function should be available
    And detect_project_type function should be available
    And categorize_staged_files function should be available
    And validate_backend_prerequisites function should be available
    And invoke_llm function should be available
    And get_available_ollama_models function should be available
    And test_model_loadability function should be available
    And find_fallback_model function should be available
    And validate_ollama_prerequisites function should be available
    And invoke_ollama function should be available

  Scenario: AICOMMIT_DIR configuration
    When I check the aicommit directory
    Then AICOMMIT_DIR should be set
    And the directory should exist
    And required subdirectories should be present
