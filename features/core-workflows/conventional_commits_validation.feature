@workflows @conventional-commits @validation @critical
Feature: Conventional Commits Validation Tests
  As a developer maintaining commit standards
  I want aicommit to validate and enforce conventional commit format
  So I can ensure consistent and meaningful commit history

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Accept standard conventional commit types
    When I validate conventional commit "feat: add OAuth2 support"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept fix type conventional commit
    When I validate conventional commit "fix: resolve null pointer exception"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept docs type conventional commit
    When I validate conventional commit "docs: update installation guide"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept style type conventional commit
    When I validate conventional commit "style: apply prettier formatting"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept refactor type conventional commit
    When I validate conventional commit "refactor: extract validation into helper"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept test type conventional commit
    When I validate conventional commit "test: add unit tests for core module"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept chore type conventional commit
    When I validate conventional commit "chore: update dependencies"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept perf type conventional commit
    When I validate conventional commit "perf: cache db query results"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept ci type conventional commit
    When I validate conventional commit "ci: add matrix strategy for multi-shell"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept build type conventional commit
    When I validate conventional commit "build: migrate to esbuild"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept revert type conventional commit
    When I validate conventional commit "revert: undo breaking auth change"
    Then validation should succeed
    And commit should be accepted

  Scenario: Accept scope in parentheses
    When I validate conventional commit "feat(auth): add session management"
    Then validation should succeed
    And scope should be accepted

  Scenario: Accept multi-word scope
    When I validate conventional commit "fix(user-profile): handle missing avatar"
    Then validation should succeed
    And multi-word scope should be accepted

  Scenario: Accept breaking change with exclamation mark
    When I validate conventional commit "feat(api)!: remove deprecated endpoint"
    Then validation should succeed
    And breaking change indicator should be accepted

  Scenario: Reject plain sentence without type
    When I validate conventional commit "added new login feature"
    Then validation should fail
    And appropriate error should be displayed

  Scenario: Reject empty commit message
    When I validate conventional commit ""
    Then validation should fail
    And appropriate error should be displayed

  Scenario: Reject uppercase type
    When I validate conventional commit "FEAT: add something"
    Then validation should fail
    And appropriate error should be displayed

  Scenario: Reject type without description
    When I validate conventional commit "feat:"
    Then validation should fail
    And appropriate error should be displayed

  Scenario: Reject type without colon
    When I validate conventional commit "feat add something"
    Then validation should fail
    And appropriate error should be displayed

  Scenario: Reject unknown type
    When I validate conventional commit "update: change some stuff"
    Then validation should fail
    And appropriate error should be displayed

  Scenario: Process commit records message verbatim in git log
    Given I have staged changes
    When I process commit "feat(core): add shell support"
    Then commit should be created successfully
    And git log should contain exact message
    And message should be recorded verbatim

  Scenario: Dry-run produces audit file
    Given I have staged changes
    When I run aicommit --dry-run
    Then FULL_PROMPT audit file should be created
    And audit trail should be maintained

  Scenario: FULL_PROMPT contains required context sections
    Given I have staged changes
    When I run aicommit --dry-run
    Then FULL_PROMPT should contain repository context
    And FULL_PROMPT should contain changes context
    And FULL_PROMPT should contain file categories
    And audit should be comprehensive

  Scenario: Conventional commit validation for feature additions
    Given I have staged changes to a feature file
    When I run aicommit
    Then generated message should start with "feat:"
    And message should follow conventional format
    And commit should be created successfully

  Scenario: Conventional commit validation for bug fixes
    Given I have staged changes to fix a bug
    When I run aicommit
    Then generated message should start with "fix:"
    And message should describe the bug fix
    And commit should be created successfully

  Scenario: Conventional commit validation for performance improvements
    Given I have staged changes to improve performance
    When I run aicommit
    Then generated message should start with "perf:"
    And message should describe the improvement
    And commit should be created successfully

  Scenario: Conventional commit validation for documentation updates
    Given I have staged changes to documentation
    When I run aicommit
    Then generated message should start with "docs:"
    And message should describe the documentation changes
    And commit should be created successfully

  Scenario: Conventional commit validation for breaking changes
    Given I have staged breaking changes
    When I run aicommit
    Then generated message should start with "feat!" or "fix!"
    And message should indicate breaking change
    And commit should be created successfully

  Scenario: Conventional commit validation for style changes
    Given I have staged style/formatting changes
    When I run aicommit
    Then generated message should start with "style:"
    And message should describe formatting changes
    And commit should be created successfully

  Scenario: Conventional commit validation for refactoring
    Given I have staged refactoring changes
    When I run aicommit
    Then generated message should start with "refactor:"
    And message should describe refactoring changes
    And commit should be created successfully

  Scenario: Conventional commit validation for test changes
    Given I have staged test-related changes
    When I run aicommit
    Then generated message should start with "test:"
    And message should describe test changes
    And commit should be created successfully

  Scenario: Conventional commit validation for build changes
    Given I have staged build system changes
    When I run aicommit
    Then generated message should start with "build:"
    And message should describe build changes
    And commit should be created successfully

  Scenario: Conventional commit validation for CI changes
    Given I have staged CI/CD changes
    When I run aicommit
    Then generated message should start with "ci:"
    And message should describe CI changes
    And commit should be created successfully

  Scenario: Conventional commit validation for chore tasks
    Given I have staged maintenance tasks
    When I run aicommit
    Then generated message should start with "chore:"
    And message should describe maintenance changes
    And commit should be created successfully

  Scenario: Conventional commit validation with scope and breaking change
    Given I have staged breaking API changes
    When I run aicommit
    Then generated message should include scope
    And generated message should include breaking change indicator
    And message should follow format "type(scope)!: description"
    And commit should be created successfully
