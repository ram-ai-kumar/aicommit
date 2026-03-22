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

  Scenario: Installation on different Linux distributions
    Given system is Ubuntu-based
    When I run installation script
    Then installation should succeed
    And distribution-specific requirements should be handled
    And package manager dependencies should be installed

  Scenario: Installation on macOS with Homebrew
    Given system is macOS with Homebrew
    When I install via Homebrew
    Then installation should succeed
    And Homebrew-specific paths should be handled
    And macOS security permissions should be managed

  Scenario: Installation on Windows with WSL
    Given system is Windows with WSL
    When I run installation script
    Then installation should succeed in WSL environment
    And Windows path integration should work
    And WSL-specific requirements should be met

  Scenario: Installation with custom shell
    Given user uses fish shell
    When I install aicommit
    Then shell completion should be installed for fish
    And PATH configuration should work for fish
    And shell-specific features should be supported

  Scenario: Installation validation with corrupted files
    Given installation files are corrupted
    When I attempt installation
    Then corruption should be detected
    And error should be clearly reported
    And cleanup should be performed

  Scenario: Installation rollback on failure
    Given installation fails midway
    When I check system state
    Then partial installation should be cleaned up
    And system should be restored to previous state
    And error logs should be preserved

  Scenario: Installation with minimal dependencies
    Given system has minimal installed packages
    When I run installation script
    Then missing dependencies should be identified
    And installation should guide dependency installation
    And alternative installation methods should be suggested

  Scenario: Installation in air-gapped environment
    Given system has no internet access
    When I install from offline package
    Then installation should succeed completely
    And all features should work offline
    And documentation should be available locally

  Scenario: Installation with custom Git configuration
    Given user has custom Git configuration
    When I install aicommit
    Then Git configuration should be respected
    And aicommit should integrate with custom Git setup
    And no conflicts should occur
