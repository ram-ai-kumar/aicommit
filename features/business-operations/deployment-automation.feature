@functional @installation @stage1
Feature: AI Commit Installation and Setup Validation
  As a developer installing aicommit
  I want the installation and setup process to be thoroughly validated
  So I can trust that the tool is properly configured and ready to use

  Background:
    Given a clean system environment

  Scenario: Fresh installation verification
    When I run the installation script
    Then the aicommit script should be installed
    And the script should be executable
    And required directories should be created
    And default configuration should be set up
    And help command should work

  Scenario: Upgrade path testing from previous version
    Given a previous version of aicommit is installed
    When I run the upgrade script
    Then existing configuration should be preserved
    And new features should be available
    And backward compatibility should be maintained
    And old deprecated features should be handled gracefully

  Scenario: Dependency validation for core requirements
    When I check system dependencies
    Then git should be available
    And bash should be version 4.0 or higher
    And curl should be available for network operations
    And sed should be available for text processing
    And awk should be available for data processing

  Scenario: PATH configuration testing
    Given aicommit is installed in custom directory
    When I check PATH configuration
    Then aicommit directory should be in PATH
    And aicommit command should be found
    And aic command should be found
    And command completion should work

  Scenario: Shell completion functionality for bash
    Given bash shell completion is installed
    When I type "aicommit --" and press tab
    Then available options should be displayed
    And completion should work for subcommands
    And completion should work for options

  Scenario: Shell completion functionality for zsh
    Given zsh shell completion is installed
    When I type "aicommit --" and press tab
    Then available options should be displayed
    And completion should work for subcommands
    And completion should work for options

  Scenario: Installation permission validation
    Given the user has standard permissions
    When I attempt installation
    Then installation should succeed in user directory
    And system-wide installation should require sudo
    And permission errors should be handled gracefully

  Scenario: Installation in custom directory
    Given AICOMMIT_HOME is set to custom directory
    When I run installation
    Then aicommit should be installed in custom directory
    And configuration should be in custom directory
    And temporary files should use custom directory

  Scenario: Installation verification script
    When I run the installation verification script
    Then all components should be verified
    And any missing components should be reported
    And verification summary should be displayed

  Scenario: Uninstallation validation
    Given aicommit is properly installed
    When I run the uninstallation script
    Then aicommit files should be removed
    And configuration files should be optionally preserved
    And PATH should be cleaned up
    And completion scripts should be removed

  Scenario: Installation with network restrictions
    Given network access is restricted
    When I attempt installation without network
    Then installation should succeed with local resources
    And offline installation should be documented
    And network-dependent features should be disabled gracefully
