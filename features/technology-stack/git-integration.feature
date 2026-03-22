@functional @integration @stage1
Feature: AI Commit Basic Integration Testing
  As a developer using aicommit
  I want basic integration with git and AI services to work seamlessly
  So I can generate commit messages efficiently in my development workflow

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Git workflow integration with add and commit
    Given I have made changes to a file
    When I add the file to staging area
    And I run aicommit command "--dry-run"
    Then a commit message should be generated
    And the message should follow conventional commits format
    And the command should exit successfully

  Scenario: Full git workflow with push
    Given I have committed changes using aicommit
    When I push to remote repository
    Then the push should succeed
    And the commit message should be properly formatted

  Scenario: Multiple backend basic connectivity with ollama
    Given ollama backend is configured
    And ollama service is running
    And I have made changes to a file
    And I add the file to staging area
    When I run aicommit command "--dry-run"
    Then the backend should respond successfully
    And a commit message should be generated

  Scenario: Simple AI model interaction with small changes
    Given I have made small code changes
    And I add the files to staging area
    When I run aicommit command "--dry-run"
    Then the AI should analyze the changes
    And generate an appropriate commit message
    And the message should reflect the nature of changes

  Scenario: File type detection for JavaScript files
    Given I have modified JavaScript files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as JavaScript
    And the commit message should be relevant to JavaScript changes

  Scenario: File type detection for Python files
    Given I have modified Python files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as Python
    And the commit message should be relevant to Python changes

  Scenario: File type detection for Ruby files
    Given I have modified Ruby files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as Ruby
    And the commit message should be relevant to Ruby changes

  Scenario: File type detection for configuration files
    Given I have modified configuration files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as configuration
    And the commit message should reflect configuration changes

  Scenario: File type detection for documentation files
    Given I have modified documentation files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as documentation
    And the commit message should reflect documentation changes

  Scenario: File type detection for test files
    Given I have modified test files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as test
    And the commit message should reflect test changes

  Scenario: File type detection for mixed file types
    Given I have modified multiple file types
    When I run aicommit command "--dry-run"
    Then all file types should be detected correctly
    And the commit message should reflect the mixed nature of changes

  Scenario: Backend connectivity with timeout handling
    Given ollama backend is configured
    And ollama service is slow to respond
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then the command should handle timeout gracefully
    And appropriate error should be displayed
    And fallback mechanisms should be attempted

  Scenario: Backend connectivity with authentication
    Given ollama backend requires authentication
    And valid credentials are configured
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then authentication should succeed
    And a commit message should be generated

  Scenario: Backend connectivity with invalid credentials
    Given ollama backend requires authentication
    And invalid credentials are configured
    And I have made changes to a file
    When I run aicommit command "--dry-run"
    Then authentication should fail
    And appropriate error should be displayed
    And no commit message should be generated

  Scenario: Integration with git hooks
    Given git pre-commit hooks are configured
    And I have made changes to a file
    When I run aicommit command
    Then git hooks should be respected
    And commit should succeed if hooks pass
    And commit should fail if hooks reject

  Scenario: Integration with git submodules
    Given repository contains git submodules
    And I have made changes to submodule files
    When I run aicommit command "--dry-run"
    Then submodule changes should be detected
    And commit message should reflect submodule changes

  Scenario: Integration with git worktrees
    Given repository uses git worktrees
    And I have made changes in worktree
    When I run aicommit command "--dry-run"
    Then worktree context should be handled correctly
    And commit message should be appropriate for worktree changes
    When I run aicommit command "--dry-run"
    Then the backend should respond successfully
    And a commit message should be generated

  Scenario: Multiple backend basic connectivity fallback
    Given primary backend is not available
    And fallback backend is configured
    And I have made changes to a file
    And I add the file to staging area
    When I run aicommit command "--dry-run"
    Then the system should fall back to secondary backend
    And a commit message should still be generated

  Scenario: Simple AI model interaction with small changes
    Given I have made small code changes
    And I add the files to staging area
    When I run aicommit command "--dry-run"
    Then the AI should analyze the changes
    And generate an appropriate commit message
    And the message should reflect the nature of changes

  Scenario: Dry-run workflow exits successfully with staged files
    Given I have staged changes
    When I run "aicommit --dry-run"
    Then the command should exit successfully
    And a commit message should be displayed
    And no actual commit should be made

  Scenario: Dry-run workflow with multiple files
    Given I have staged multiple files
    When I run "aicommit --dry-run"
    Then the command should exit successfully
    And the message should reference all files
    And the message should be comprehensive

  Scenario: Help system integration with git workflow
    Given I am in a git repository
    When I run "aicommit --help"
    Then the command should exit successfully
    And usage should be displayed
    And git-related options should be documented

  Scenario: File type detection integration
    Given I have staged different file types
    When I run "aicommit --dry-run"
    Then file types should be detected correctly
    And commit message should reflect file types
    And processing should be appropriate for each type

  Scenario: Branch name integration
    Given I am on a feature branch
    And I have staged changes
    When I run "aicommit --dry-run"
    Then branch context should be considered
    And commit message should be appropriate for branch

  Scenario: Merge conflict handling
    Given there are merge conflicts
    When I run "aicommit --dry-run"
    Then conflicts should be detected
    And appropriate error should be shown
    And processing should be halted gracefully

  Scenario: Empty repository integration
    Given I am in a new git repository
    And I have staged initial files
    When I run "aicommit --dry-run"
    Then initial commit should be detected
    And message should be appropriate for initial commit

  Scenario: Large repository integration
    Given I am in a repository with many files
    And I have staged changes
    When I run "aicommit --dry-run"
    Then processing should complete in reasonable time
    And message should be generated successfully

  Scenario: Subdirectory integration
    Given I have staged files in subdirectories
    When I run "aicommit --dry-run"
    Then subdirectory structure should be handled
    And message should reflect directory context

  Scenario: Staged files with special characters
    Given I have staged files with special characters
    When I run "aicommit --dry-run"
    Then special characters should be handled
    And processing should complete successfully

  Scenario: Unstaged changes handling
    Given I have unstaged changes
    And I have staged changes
    When I run "aicommit --dry-run"
    Then only staged changes should be processed
    And unstaged changes should be ignored

  Scenario: Git hooks integration
    Given git hooks are configured
    And I have staged changes
    When I run "aicommit --dry-run"
    Then hooks should not interfere with dry-run
    And processing should complete successfully

  Scenario: Remote repository integration
    Given I have a remote configured
    And I have staged changes
    When I run "aicommit --dry-run"
    Then remote status should not affect dry-run
    And message should be generated successfully

  Scenario: Detached HEAD state integration
    Given I am in detached HEAD state
    And I have staged changes
    When I run "aicommit --dry-run"
    Then detached state should be handled
    And message should be generated appropriately

  Scenario: Git configuration integration
    Given git configuration is set
    And I have staged changes
    When I run "aicommit --dry-run"
    Then git config should be respected
    And processing should work correctly

  Scenario: File type detection for JavaScript files
    Given I have modified JavaScript files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as JavaScript
    And the commit message should be relevant to JavaScript changes

  Scenario: File type detection for Python files
    Given I have modified Python files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as Python
    And the commit message should be relevant to Python changes

  Scenario: File type detection for configuration files
    Given I have modified configuration files
    When I run aicommit command "--dry-run"
    Then the file type should be detected as configuration
    And the commit message should reflect configuration changes

  Scenario: Integration with staged changes only
    Given I have both staged and unstaged changes
    When I run aicommit command "--dry-run"
    Then only staged changes should be analyzed
    And unstaged changes should be ignored

  Scenario: Integration with multiple staged files
    Given I have staged multiple files
    When I run aicommit command "--dry-run"
    Then all staged files should be analyzed
    And the commit message should cover all changes

  Scenario: Integration with binary files in staging
    Given I have staged binary files
    When I run aicommit command "--dry-run"
    Then binary files should be excluded from analysis
    And text files should still be analyzed

  Scenario: Integration with large diff
    Given I have staged a large diff
    When I run aicommit command "--dry-run"
    Then the diff should be truncated appropriately
    And a meaningful commit message should still be generated

  Scenario: Integration with empty staging area
    Given no files are staged
    When I run aicommit command "--dry-run"
    Then the command should fail gracefully
    And appropriate error message should be shown

  Scenario: Integration test cleanup
    Given aicommit temporary files exist
    When the test completes
    Then temporary files should be cleaned up
    And the repository should be in a clean state
