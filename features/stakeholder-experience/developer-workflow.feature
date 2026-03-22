@functional @enhanced @stage1
Feature: Enhanced AI Commit Basic Functionality
  As a developer using aicommit
  I want enhanced basic functionality to work reliably across different environments
  So I can trust the tool for consistent commit message generation

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Configuration file validation with JSON support
    Given a JSON configuration file exists with valid settings
    When I load the configuration
    Then the configuration should be parsed successfully
    And AI_BACKEND should be set from the config file
    And AI_MODEL should be set from the config file

  Scenario: Configuration file validation with YAML support
    Given a YAML configuration file exists with valid settings
    When I load the configuration
    Then the configuration should be parsed successfully
    And the settings should be applied correctly

  Scenario: Environment variable precedence testing
    Given AI_BACKEND is set to "test-backend" in environment
    And a configuration file sets AI_BACKEND to "config-backend"
    When I check the effective configuration
    Then the environment variable should take precedence
    And AI_BACKEND should be "test-backend"

  Scenario: Cross-platform compatibility on Linux
    Given the system is Linux-based
    When I run aicommit basic commands
    Then the commands should execute successfully
    And paths should be handled correctly

  Scenario: Cross-platform compatibility on macOS
    Given the system is macOS-based
    When I run aicommit basic commands
    Then the commands should execute successfully
    And paths should be handled correctly

  Scenario: Version detection and compatibility checks
    When I check aicommit version
    Then a version number should be returned
    And the version should follow semantic versioning
    And compatibility with current system should be verified

  Scenario: Plugin system basic validation
    Given the plugins directory exists
    When I scan for available plugins
    Then the plugin system should initialize
    And available plugins should be listed
    And plugin metadata should be valid

  Scenario: Configuration validation with missing required fields
    Given a configuration file with missing required fields
    When I attempt to load the configuration
    Then validation should fail
    And appropriate error message should be displayed

  Scenario: Configuration validation with invalid values
    Given a configuration file with invalid AI_TIMEOUT value
    When I attempt to load the configuration
    Then validation should fail
    And error should indicate invalid timeout format

  Scenario: Configuration inheritance testing
    Given a global configuration file exists
    And a project-specific configuration file exists
    When I load the configuration
    Then project settings should override global settings
    And inherited settings should be preserved

  Scenario: Configuration validation with malformed JSON
    Given a configuration file contains malformed JSON
    When I attempt to load the configuration
    Then validation should fail
    And error should indicate JSON syntax error
    And default configuration should be used as fallback

  Scenario: Configuration validation with malformed YAML
    Given a configuration file contains malformed YAML
    When I attempt to load the configuration
    Then validation should fail
    And error should indicate YAML syntax error
    And default configuration should be used as fallback

  Scenario: Environment variable type validation
    Given AI_TIMEOUT is set to "invalid-number" in environment
    When I load the configuration
    Then environment variable validation should fail
    And error should indicate invalid timeout format
    And default timeout should be used

  Scenario: Cross-platform compatibility on Windows
    Given the system is Windows-based
    When I run aicommit basic commands
    Then the commands should execute successfully
    And Windows paths should be handled correctly
    And shell commands should be compatible

  Scenario: Cross-platform path handling
    Given files exist with spaces in names
    When I run aicommit on different platforms
    Then file paths should be handled consistently
    And path separators should be normalized
    And operations should succeed across platforms

  Scenario: Version compatibility check with minimum requirements
    Given the system has minimum required dependencies
    When I check aicommit version compatibility
    Then compatibility should be confirmed
    And all required dependencies should be available
    And deprecated features should be identified

  Scenario: Version compatibility check with outdated system
    Given the system has outdated dependencies
    When I check aicommit version compatibility
    Then compatibility issues should be reported
    And upgrade recommendations should be provided
    And fallback mode should be available

  Scenario: Plugin system with invalid plugin
    Given a plugin with invalid metadata exists
    When I scan for available plugins
    Then the invalid plugin should be skipped
    And error should be logged for the plugin
    And other valid plugins should still load

  Scenario: Plugin system with missing dependencies
    Given a plugin requires missing dependencies
    When I attempt to load the plugin
    Then dependency check should fail
    And appropriate error should be displayed
    And plugin should be marked as unavailable

  Scenario: Configuration file permissions handling
    Given a configuration file has restrictive permissions
    When I attempt to load the configuration
    Then permission error should be handled gracefully
    And default configuration should be used
    And user should be informed about permission issue

  Scenario: Configuration file encoding handling
    Given a configuration file uses UTF-8 encoding with special characters
    When I load the configuration
    Then the file should be read correctly
    And special characters should be preserved
    And configuration should be parsed successfully

  Scenario: Environment variable expansion in configuration
    Given a configuration file contains environment variable references
    When I load the configuration
    Then environment variables should be expanded
    And expanded values should be used in configuration
    And missing variables should be handled gracefully
