@integration @critical
Feature: AI Commit End-to-End Integration Tests
  As a developer using aicommit in production
  I want complete workflows to function correctly
  So I can rely on the tool for real-world usage

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean
    And ollama is running with required models

  Scenario: Complete dry-run workflow with multiple files
    Given I have staged multiple files of different types
    When I run "aicommit --dry-run"
    Then the command should exit successfully
    And staged files summary should be displayed
    And dry-run message should be shown
    And ollama status should be displayed
    And FULL_PROMPT file should be created
    And FULL_PROMPT should be non-empty
    And temporary files should be cleaned up after completion

  Scenario: Complete dry-run workflow with verbose output
    Given I have staged files
    When I run "aicommit --dry-run --verbose"
    Then the command should exit successfully
    And temporary directory path should be displayed
    And CHANGES_CONTEXT path should be displayed
    And detailed processing information should be shown

  Scenario: Multi-file staging workflow
    Given I have staged JavaScript, Python, and shell files
    When I run "aicommit --dry-run"
    Then the command should exit successfully
    And file count should reflect all staged files
    And all file types should be processed correctly

  Scenario: Failure workflow with no staged changes
    Given I have no staged changes
    When I run "aicommit --dry-run"
    Then the command should fail with exit code 1
    And "No staged changes" message should be displayed

  Scenario: Regenerate workflow without cached prompt
    Given I have staged files
    And no cached prompt exists
    When I run "aicommit --regenerate"
    Then the command should fail with exit code 1
    And "No cached prompt" message should be displayed

  Scenario: Help system workflow
    When I run "aicommit --help"
    Then the command should exit successfully
    And usage information should be displayed
    And available options should be documented

  Scenario: Short help flag workflow
    When I run "aicommit -h"
    Then the command should exit successfully
    And usage information should be displayed

  Scenario: AIC alias workflow with no staged changes
    Given I have no staged changes
    When I run "aic"
    Then the command should fail with exit code 1
    And "No staged changes" message should be displayed

  Scenario: Unknown option handling workflow
    When I run "aicommit --this-flag-does-not-exist"
    Then the command should fail with exit code 1
    And appropriate error message should be displayed

  Scenario: Temporary directory cleanup workflow
    Given I have staged files
    When I run "aicommit --dry-run" in a subshell
    Then ephemeral context files should be removed after completion
    And CHANGES_CONTEXT should not exist
    And FILE_CONTEXT should not exist
    And FILE_COUNT should not exist

  Scenario: Context file creation workflow
    Given I have staged files
    When I run "aicommit --dry-run"
    Then CHANGES_CONTEXT should be created
    And FILE_CONTEXT should be created
    And CHANGE_STATS should be created
    And FILE_COUNT should be created

  Scenario: Full prompt audit workflow
    Given I have staged files
    When I run "aicommit --dry-run"
    Then FULL_PROMPT should contain repository context
    And FULL_PROMPT should contain changes context
    And FULL_PROMPT should contain file categories
    And audit trail should be maintained
