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
