# BDD Step Definitions Optimization Guide

## Overview
This guide explains how to use the standardized step definitions to make BDD tests modular and reusable across all feature files.

## Standardized Step Categories

### 1. Environment Setup Steps
- `Given aicommit is properly installed`
- `Given a git repository is initialized`
- `Given the working directory is clean`
- `Given a clean system environment`

### 2. File and Change Management Steps
- `Given I have made changes to a file`
- `Given I have made changes to multiple files`
- `Given I have made small code changes`
- `Given I have made large changes requiring processing`
- `Given I have made complex changes`
- `Given I have made many file changes`
- `Given I have made repeated similar changes`
- `Given I have made standard changes`

### 3. Configuration Steps
- `Given AI_BACKEND is set to "backend_name"`
- `Given AI_TIMEOUT is set to "timeout_value"`
- `Given AI_PROMPT_FILE points to non-existent file`
- `Given a configuration file exists with valid settings`
- `Given a configuration file with missing required fields`
- `Given a configuration file with invalid AI_TIMEOUT value`

### 4. System Condition Steps
- `Given network connection is unstable`
- `Given system has limited available memory`
- `Given system has limited CPU resources`
- `Given disk I/O is slow`
- `Given network bandwidth is limited`
- `Given ollama backend is configured`
- `Given ollama service is running`
- `Given ollama backend requires authentication`
- `Given ollama backend has rate limits`
- `Given ollama backend returns malformed JSON`

### 5. Repository and File Type Steps
- `Given repository contains over 1000 files`
- `Given I have modified JavaScript files`
- `Given I have modified Python files`
- `Given I have modified Ruby files`
- `Given I have modified configuration files`
- `Given I have modified documentation files`
- `Given I have modified test files`
- `Given I have modified multiple file types`

### 6. Action Steps
- `When I run aicommit command "command"`
- `When I run "command"`
- `When I load the configuration`
- `When I check the effective configuration`
- `When I check aicommit version`
- `When I scan for available plugins`
- `When I attempt to load the configuration`
- `When I validate backend prerequisites`
- `When I run installation script`
- `When I run upgrade script`
- `When I check system dependencies`

### 7. Verification Steps
- `Then the command should succeed`
- `Then the command should fail`
- `Then the command should fail with exit code 1`
- `Then a commit message should be generated`
- `Then the message should follow conventional commits format`
- `Then AI_BACKEND should be set from the config file`
- `Then AI_MODEL should be set from the config file`
- `Then the environment variable should take precedence`
- `Then AI_BACKEND should be "expected_value"`
- `Then a version number should be returned`
- `Then the version should follow semantic versioning`
- `Then the plugin system should initialize`
- `Then available plugins should be listed`
- `Then plugin metadata should be valid`
- `Then validation should fail`
- `Then appropriate error message should be displayed`
- `Then error should indicate error_type`
- `Then default configuration should be used as fallback`

### 8. Performance Steps
- `Then processing should complete within reasonable time`
- `Then memory usage should remain within limits`
- `Then performance should be acceptable for large repos`
- `Then network failures should be detected`
- `Then retry mechanisms should be attempted`
- `Then graceful degradation should occur`
- `Then user should be informed about topic`
- `Then concurrent access should be detected`
- `Then lock mechanism should prevent conflicts`
- `Then operation should wait or fail gracefully`
- `Then memory constraints should be detected`
- `Then processing should be optimized for low memory`
- `Then large changes should be processed in chunks`
- `Then CPU usage should be optimized`
- `Then system responsiveness should be maintained`

### 9. Configuration Management Steps
- `Then new configuration should be loaded automatically`
- `Then ongoing operations should complete with old settings`
- `Then new operations should use updated settings`
- `Then nested structures should be parsed correctly`
- `Then array values should be accessible`
- `Then object properties should be accessible`
- `Then validation should pass for valid structures`
- `Then valid configurations should pass validation`
- `Then invalid configurations should fail with specific errors`
- `Then schema violations should be clearly reported`
- `Then default values should be used for missing optional fields`
- `Then project settings should override user settings`
- `Then user settings should override global settings`
- `Then inheritance hierarchy should be respected`
- `Then final configuration should reflect all overrides`

## Usage Guidelines

### 1. Use Standardized Steps
Always prefer using the standardized steps over creating new ones. This ensures:
- Reusability across features
- Consistent behavior
- Easier maintenance
- Better test coverage

### 2. Parameterize Steps
Use parameters to make steps more flexible:
```gherkin
Given I have modified JavaScript files  # Standard
Given I have modified Python files     # Standard
Given I have modified Ruby files        # Standard
```

### 3. Combine Standard Steps
Create complex scenarios by combining standard steps:
```gherkin
Scenario: Complex workflow with performance constraints
  Given aicommit is properly installed
  And a git repository is initialized
  And the working directory is clean
  And system has limited available memory
  And I have made large changes requiring processing
  When I run aicommit command "--dry-run"
  Then processing should complete within reasonable time
  And memory usage should remain within limits
  And a commit message should be generated
  And user should be informed about memory usage
```

### 4. Add New Steps Only When Necessary
Only add new steps when:
- No existing step covers the functionality
- The step is fundamentally different from existing ones
- The step will be reused across multiple features

### 5. Keep Steps Atomic
Each step should:
- Do one thing well
- Be independent of other steps
- Have clear, descriptive names
- Be testable in isolation

## Migration Strategy

### Step 1: Identify Common Patterns
Review existing feature files and identify:
- Repeated step patterns
- Similar functionality with different wording
- Opportunities for standardization

### Step 2: Replace with Standard Steps
Replace non-standard steps with standardized equivalents:
```gherkin
# Before
Given the system is Linux-based
When I run aicommit basic commands
Then the commands should execute successfully

# After
Given aicommit is properly installed
And a git repository is initialized
And the working directory is clean
When I run aicommit command "--dry-run"
Then the command should succeed
```

### Step 3: Test and Validate
- Run tests to ensure functionality is preserved
- Verify that all scenarios still pass
- Check for any missing step definitions

### Step 4: Document and Share
- Document any new standard steps created
- Share the updated patterns with the team
- Update this guide with new learnings

## Benefits of Standardization

1. **Reduced Maintenance**: Fewer unique steps to maintain
2. **Better Reusability**: Steps work across multiple features
3. **Consistent Behavior**: Same step behaves consistently everywhere
4. **Easier Onboarding**: New team members can use existing patterns
5. **Improved Test Coverage**: Standard steps are well-tested
6. **Faster Development**: Less time writing new step definitions
7. **Better Documentation**: Clear patterns and examples

## Best Practices

1. **Use Descriptive Names**: Step names should clearly indicate what they do
2. **Keep Parameters Simple**: Use simple, readable parameters
3. **Handle Edge Cases**: Standard steps should handle common edge cases
4. **Provide Good Error Messages**: Clear feedback when steps fail
5. **Document Assumptions**: Clearly document what each step assumes
6. **Test Independently**: Each step should work in isolation
7. **Version Control**: Track changes to step definitions carefully

## Example Feature File

Here's an example of a well-structured feature file using standardized steps:

```gherkin
@functional @performance @stage2
Feature: AI Commit Performance Testing
  As a developer using aicommit
  I want the system to perform well under various conditions
  So I can rely on it for my daily work

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Performance with limited memory
    Given system has limited available memory
    And I have made large changes requiring processing
    When I run aicommit command "--dry-run"
    Then processing should complete within reasonable time
    And memory usage should remain within limits
    And a commit message should be generated
    And user should be informed about memory usage

  Scenario: Performance with multiple files
    Given repository contains over 1000 files
    And I have made changes to multiple files
    When I run aicommit command "--dry-run"
    Then processing should complete within reasonable time
    And performance should be acceptable for large repos
    And a commit message should be generated
```

This approach ensures consistency, reusability, and maintainability across all BDD tests.
