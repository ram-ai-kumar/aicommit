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
    And Then the main functions should be available
    And And aicommit command should be defined
    And And aic command should be defined

  Scenario: Default configuration validation
    When I check the default configuration
    And Then AI_BACKEND should be "ollama"
    And And AI_MODEL should be "qwen2.5-coder:latest"
    And And AI_TIMEOUT should be "120"
    And And AI_PROMPT_FILE should exist

  Scenario: Help system functionality
    When I run "aicommit --help"
    And Then the command should exit successfully
    And And output should contain "Usage: aicommit [OPTIONS]"
    And And output should contain "--dry-run"
    And And output should contain "--verbose"

  Scenario: Help system short flag
    When I run "aicommit -h"
    And Then the command should exit successfully
    And And output should contain "Usage: aicommit [OPTIONS]"

  Scenario: Temporary directory management
    When I request aicommit temporary directory
    And Then the directory should be created
    And And the directory should be under "/tmp/.aicommit"
    And And the directory should have appropriate permissions

  Scenario: Ollama model listing
    Given ollama is available and running
    When I list available models
    And Then I should see model names only
    And And model IDs should not be exposed
    And And the command should succeed

  Scenario: Model loadability verification
    Given ollama is available and running
    And a test model is available
    When I test model loadability
    And Then the test should pass
    And And the model should respond correctly

  Scenario: Fallback model selection
    Given ollama is available and running
    And multiple models are available
    When primary model is not available
    And Then a suitable fallback model should be selected
    And And the fallback should be loadable

  Scenario: Library functions availability
    When I source the aicommit script
    And Then validate_prerequisites function should be available
    And And get_aicommit_tmp_dir function should be available
    And And build_file_context function should be available
    And And filter_and_truncate_diff function should be available
    And And build_ai_context function should be available
    And And generate_commit_message function should be available
    And And process_commit function should be available
    And And cleanup_aicommit_ephemeral function should be available
    And And cleanup_aicommit_all function should be available
    And And display_setup_info function should be available
    And And display_error function should be available
    And And detect_project_type function should be available
    And And categorize_staged_files function should be available
    And And validate_backend_prerequisites function should be available
    And And invoke_llm function should be available
    And And get_available_ollama_models function should be available
    And And test_model_loadability function should be available
    And And find_fallback_model function should be available
    And And validate_ollama_prerequisites function should be available
    And And invoke_ollama function should be available

  Scenario: AICOMMIT_DIR configuration
    When I check the aicommit directory
    And Then AICOMMIT_DIR should be set
    And And the directory should exist
    And And required subdirectories should be present
