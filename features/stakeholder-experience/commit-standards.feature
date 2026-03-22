@workflows @conventional-commits @critical
Feature: Conventional Commit Generation
  As a developer
  I want aicommit to generate conventional commit messages
  So that I can maintain consistent commit history

  @conventional-commits @validation
  Scenario: Generate conventional commit message for feature addition
    Given I have staged changes to a JavaScript feature file
    And I have Ollama running with qwen2.5-coder model
    When I run aicommit
    Then it should generate a conventional commit message
    And the message should start with "feat:"
    And the commit should be created successfully

  @conventional-commits @types
  Scenario: Generate commit messages for different change types
    Given I have staged changes
    And I have aicommit configured
    When I run aicommit for different change types
    Then it should generate appropriate conventional commit prefixes
    And the messages should follow conventional commit format

  Scenario Outline: Bug fix commit
    Given I have staged changes to fix a bug
    When I run aicommit
    Then it should generate a commit message starting with "fix:"
    And the message should describe the bug fix

  Scenario Outline: Performance improvement commit
    Given I have staged changes to improve performance
    When I run aicommit
    Then it should generate a commit message starting with "perf:"
    And the message should describe the improvement

  Scenario Outline: Documentation update commit
    Given I have staged changes to documentation
    When I run aicommit
    Then it should generate a commit message starting with "docs:"
    And the message should describe the documentation changes

  Scenario Outline: Breaking change commit
    Given I have staged breaking changes
    When I run aicommit
    Then it should generate a commit message starting with "feat!" or "fix!"
    And the message should include BREAKING CHANGE section
