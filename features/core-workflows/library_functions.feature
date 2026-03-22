@unit-testing @critical
Feature: AI Commit Library Function Tests
  As a developer maintaining aicommit
  I want individual library functions to work correctly
  So the overall system can rely on solid building blocks

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Backend validation rejects unknown backend
    Given AI_BACKEND is set to "nonexistent"
    When I validate backend prerequisites
    Then validation should fail
    And error should mention "Unsupported backend"

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

  Scenario: LLM routing with unknown backend fails
    Given AI_BACKEND is set to "unknown_llm"
    When I invoke LLM with test parameters
    Then the command should fail
    And error should mention "Unsupported backend"

  Scenario: Ollama validation fails when process not running
    Given pgrep finds no ollama process
    When I validate ollama prerequisites for "qwen2.5-coder:latest"
    Then validation should fail
    And error should mention "not running"

  Scenario: Ollama validation fails when model not found
    Given ollama is running
    But model list does not contain the requested model
    When I validate ollama prerequisites for "missing-model"
    Then validation should fail
    And error should mention model not found

  Scenario: Project type detection for Ruby on Rails
    Given Gemfile exists in repository
    When I detect project type
    Then "rails/ruby" should be returned
    And detection should succeed

  Scenario: Project type detection for Node.js
    Given package.json exists in repository
    When I detect project type
    Then "node/javascript" should be returned
    And detection should succeed

  Scenario: Project type detection for Python
    Given requirements.txt exists in repository
    When I detect project type
    Then "python" should be returned
    And detection should succeed

  Scenario: Project type detection for Go
    Given go.mod file is staged
    When I detect project type
    Then "go" should be returned
    And detection should succeed

  Scenario: Project type detection for Rust
    Given Cargo.toml file is staged
    When I detect project type
    Then "rust" should be returned
    And detection should succeed

  Scenario: Project type detection for Java
    Given pom.xml file is staged
    When I detect project type
    Then "java" should be returned
    And detection should succeed

  Scenario: Project type detection prefers Gemfile over others
    Given Gemfile and package.json both exist
    When I detect project type
    Then "rails/ruby" should be returned
    And first match should be preferred

  Scenario: Change concentration analysis for single file
    Given only one file is changed
    When I analyze change concentration
    Then concentration should be 100 percent
    And analysis should be accurate

  Scenario: Change concentration analysis for multiple directories
    Given files are spread across multiple directories
    When I analyze change concentration
    Then concentration percentages should be calculated per directory
    And analysis should reflect distribution

  Scenario: New files ratio detection with no files
    Given no staged files exist
    When I detect new files ratio
    Then "0|0|0" should be returned
    And calculation should handle empty input

  Scenario: New files ratio detection with new file
    Given a newly added file is staged
    When I detect new files ratio
    Then new file count should be reflected
    And ratio should be calculated correctly

  Scenario: Upgrade pattern detection for dependency updates
    Given package.json and package-lock.json are staged
    When I detect upgrade pattern
    Then "dependency_upgrade" should be returned
    And pattern should be identified correctly

  Scenario: Upgrade pattern detection for migrations
    Given db/migrate files are staged
    When I detect upgrade pattern
    Then "migration" should be returned
    And pattern should be identified correctly

  Scenario: File categorization produces correct headers
    Given source files are staged
    When I categorize staged files
    Then "FILE CATEGORIES" header should be produced
    And categorization should succeed

  Scenario: File categorization classifies source files correctly
    Given JavaScript and shell files are staged
    When I categorize staged files
    Then "Functional Source" category should be present
    And files should be classified correctly

  Scenario: File categorization classifies test files correctly
    Given test files are staged
    When I categorize staged files
    Then "Tests" category should be present
    And test files should be identified

  Scenario: File categorization excludes sensitive files
    Given .env and normal files are staged
    When I categorize staged files
    Then .env files should not appear in output
    And sensitive files should be excluded

  Scenario: Enhanced context building includes project type
    Given files are staged
    When I build enhanced context
    Then "ENHANCED CONTEXT" header should be present
    And "Project Type" line should be included
    And context should be comprehensive

  Scenario: Core function creates temporary directory correctly
    When I get aicommit temporary directory
    Then directory should be created
    And directory should be under "/tmp/.aicommit"
    And directory should have 700 permissions

  Scenario: Core function returns same directory on repeated calls
    When I get aicommit temporary directory twice
    Then both calls should return same path
    And directory should be consistent

  Scenario: File context building creates required files
    Given files are staged
    When I build file context
    Then FILE_CONTEXT should be created
    And CHANGE_STATS should be created
    And FILE_COUNT should be created

  Scenario: File context building counts files correctly
    Given multiple files are staged
    When I build file context
    Then file count should reflect staged files
    And counting should be accurate

  Scenario: File context excludes sensitive files from stats
    Given .env and normal files are staged
    When I build file context
    Then .env should not appear in CHANGE_STATS
    But both files should be counted in FILE_COUNT

  Scenario: Diff filtering excludes .env files
    Given .env file diff contains sensitive content
    When I filter and truncate the diff
    Then sensitive content should not appear in output
    And entire .env diff should be removed

  Scenario: Diff filtering excludes lock files
    Given package-lock.json diff is present
    When I filter and truncate the diff
    Then lockfile content should be excluded
    And "lockfileVersion" should not appear

  Scenario: Diff filtering truncates large markdown files
    Given README.md with many additions is staged
    When I filter and truncate the diff
    Then only 20 or fewer addition lines should remain
    And truncation notice should be added

  Scenario: Diff filtering truncates large source files
    Given source file with many additions is staged
    When I filter and truncate the diff
    Then only 80 or fewer addition lines should remain
    And truncation notice should be added

  Scenario: Output formatter displays setup information
    Given file count and list are provided
    When I display setup information
    Then file count should be included
    And file list should be displayed
    And ollama status should be mentioned

  Scenario: Output formatter displays commit message in box
    Given a commit message is provided
    When I display commit message
    Then message should be wrapped in a box
    And "Suggested Commit" header should be present
    And message content should be displayed

  Scenario: Output formatter displays error with icon
    Given an error message is provided
    When I display error
    Then error icon should be shown
    And error message should be displayed
    And formatting should be appropriate

  Scenario: Output formatter displays success message
    When I display success message
    Then checkmark icon should be shown
    And "Committed" text should be displayed
    And success should be indicated

  Scenario: Output formatter displays commit confirmation
    When I display commit confirmation
    Then "y/n/e" prompt should be shown
    And confirmation options should be presented
