@unit-testing @critical @configuration @stage2
Feature: AI Commit Advanced Configuration Management
  As a developer maintaining aicommit
  I want comprehensive configuration management to work reliably
  So the system can handle complex configuration scenarios

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Configuration file hot reloading
    Given aicommit is running with current configuration
    And configuration file is modified during operation
    When configuration changes are detected
    Then new configuration should be loaded automatically
    And ongoing operations should complete with old settings
    And new operations should use updated settings
    And user should be informed about configuration reload

  Scenario: Configuration validation with complex nested structures
    Given configuration file contains complex nested structures
    And arrays and objects are properly formatted
    When I load the configuration
    Then nested structures should be parsed correctly
    And array values should be accessible
    And object properties should be accessible
    And validation should pass for valid structures

  Scenario: Configuration schema validation
    Given configuration schema is defined
    And configuration file is provided
    When I validate configuration against schema
    Then valid configurations should pass validation
    And invalid configurations should fail with specific errors
    And schema violations should be clearly reported
    And default values should be used for missing optional fields

  Scenario: Configuration inheritance and overrides
    Given global configuration exists
    And user configuration exists
    And project configuration exists
    When I load configuration
    Then project settings should override user settings
    And user settings should override global settings
    And inheritance hierarchy should be respected
    And final configuration should reflect all overrides

  Scenario: Configuration template generation
    Given user wants to create new configuration
    When I generate configuration template
    Then template should include all available options
    And default values should be reasonable
    And comments should explain each option
    And template should be valid configuration

  Scenario: Configuration migration between versions
    Given old version configuration exists
    And new version has different configuration structure
    When I migrate configuration
    Then old settings should be mapped to new structure
    And deprecated settings should be handled gracefully
    And migration warnings should be displayed
    And new configuration should be functional

  Scenario: Configuration backup and restore
    Given working configuration exists
    When I create configuration backup
    Then backup should contain all current settings
    And backup should be timestamped
    And backup should be restorable
    And restore should return system to previous state

  Scenario: Configuration environment variable expansion
    Given configuration contains environment variable references
    And environment variables are set
    When I load configuration
    Then variables should be expanded correctly
    And missing variables should use defaults
    And expansion errors should be handled gracefully
    And final values should be as expected

  Scenario: Configuration validation with custom rules
    Given custom validation rules are defined
    And configuration file is provided
    When I validate configuration
    Then custom rules should be applied
    And rule violations should be reported
    And custom error messages should be displayed
    And validation should be comprehensive

  Scenario: Configuration performance optimization
    Given configuration is large and complex
    When I load configuration repeatedly
    Then loading should be optimized with caching
    And cache invalidation should work correctly
    And performance should be acceptable
    And memory usage should be reasonable

  Scenario: Configuration security validation
    Given configuration contains sensitive information
    When I validate configuration security
    Then sensitive values should be detected
    And encryption should be validated
    And access permissions should be checked
    And security warnings should be displayed

  Scenario: Configuration debugging and diagnostics
    Given configuration is not working as expected
    When I run configuration diagnostics
    Then current configuration should be displayed
    And effective values should be shown
    And inheritance chain should be visible
    And potential issues should be identified

  Scenario: Configuration API integration
    Given external configuration API is available
    When I load configuration from API
    Then API authentication should work
    And remote configuration should be cached
    And network failures should be handled
    And local fallback should be available

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

  Scenario: Temporary directory creation and permissions
    When I request aicommit temporary directory
    Then the directory should be created
    And the directory should be under "/tmp/.aicommit"
    And the directory should have 700 permissions
    And the directory should not be world-readable
    And the directory should not be world-writable
    And the directory should not be world-executable

  Scenario: Temporary directory uniqueness per repository
    When I request aicommit temporary directory
    Then the directory path should include repository name
    And the directory should be unique per repository
    And the directory should not be global "/tmp/.aicommit"

  Scenario: Project type detection for Ruby on Rails
    Given a Gemfile exists in the repository
    When I detect project type
    Then the type should be "rails/ruby"

  Scenario: Project type detection for Node.js
    Given a package.json exists in the repository
    When I detect project type
    Then the type should be "node/javascript"

  Scenario: Project type detection for Python
    Given a requirements.txt exists in the repository
    When I detect project type
    Then the type should be "python"

  Scenario: Project type detection for Go
    Given a go.mod exists in the repository
    When I detect project type
    Then the type should be "go"

  Scenario: Project type detection for Rust
    Given a Cargo.toml exists in the repository
    When I detect project type
    Then the type should be "rust"

  Scenario: Project type detection for Java Maven
    Given a pom.xml exists in the repository
    When I detect project type
    Then the type should be "java/maven"

  Scenario: Project type detection for Java Gradle
    Given a build.gradle exists in the repository
    When I detect project type
    Then the type should be "java/gradle"

  Scenario: Project type detection for PHP
    Given a composer.json exists in the repository
    When I detect project type
    Then the type should be "php"

  Scenario: Project type detection for Docker
    Given a Dockerfile exists in the repository
    When I detect project type
    Then the type should be "docker"

  Scenario: Project type detection for Terraform
    Given a main.tf exists in the repository
    When I detect project type
    Then the type should be "terraform"

  Scenario: Project type detection for Kubernetes
    Given a k8s-deployment.yaml exists in the repository
    When I detect project type
    Then the type should be "kubernetes"

  Scenario: Project type detection for generic
    Given no known project files exist
    When I detect project type
    Then the type should be "generic"

  Scenario: File categorization for configuration files
    Given I have staged configuration files
    When I categorize staged files
    Then config files should be categorized as "config"
    And source files should be categorized as "source"
    And documentation files should be categorized as "docs"

  Scenario: File categorization excludes sensitive files
    Given I have staged sensitive files
    When I categorize staged files
    Then .env files should be excluded
    And .key files should be excluded
    And .pem files should be excluded
    And secret files should be excluded

  Scenario: Output formatter displays setup information
    Given I have 3 staged files
    When I display setup information
    Then output should mention file count
    And output should list file names
    And output should mention Ollama status

  Scenario: Output formatter handles single file
    Given I have 1 staged file
    When I display setup information
    Then output should mention "1 file"
    And output should mention the file name

  Scenario: Output formatter handles multiple files
    Given I have 5 staged files
    When I display setup information
    Then output should mention "5 files"
    And output should list multiple files

  Scenario: Error formatter displays error message
    When I display error message "Test error"
    Then error should be displayed prominently
    And error should be clearly formatted

  Scenario: Setup info formatter includes model information
    Given AI_MODEL is set to "test-model"
    When I display setup information
    Then output should mention the model name
    And output should include backend information

  Scenario: Context builder handles empty staged files
    Given no files are staged
    When I build file context
    Then context should be empty
    And no files should be processed

  Scenario: Context builder handles multiple file types
    Given I have staged multiple file types
    When I build file context
    Then each file type should be processed appropriately
    And context should include file statistics

  Scenario: Context builder excludes lock files
    Given I have staged package-lock.json
    When I build file context
    Then lock file content should be excluded
    And file should be mentioned in statistics

  Scenario: Context builder excludes binary files
    Given I have staged binary files
    When I build file context
    Then binary diffs should be excluded
    And binary files should be mentioned in statistics

  Scenario: Diff filter handles completely empty input
    When I filter and truncate empty diff
    Then result should be empty
    And no error should occur

  Scenario: Diff filter handles large diffs
    Given I have a very large diff
    When I filter and truncate the diff
    Then diff should be truncated appropriately
    And important content should be preserved

  Scenario: Cleanup functions remove ephemeral files
    Given temporary files exist
    When I cleanup ephemeral files
    Then ephemeral files should be removed
    And core files should remain

  Scenario: Cleanup functions remove all files
    Given all temporary files exist
    When I cleanup all files
    Then all temporary files should be removed
    And directory should be clean

  Scenario: Prerequisites validation checks core requirements
    When I validate prerequisites
    Then git should be available
    And required directories should exist
    And configuration files should be present

  Scenario: Prerequisites validation fails without git
    Given git is not available
    When I validate prerequisites
    Then validation should fail
    And error should mention git requirement
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
