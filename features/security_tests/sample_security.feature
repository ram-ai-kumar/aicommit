@security
Feature: Sample Security Test
  As a developer
  I want to verify Cucumber setup is working
  So that I can run BDD tests

  Scenario: Basic Cucumber functionality test
    Given I have a working aicommit installation
    When I run cucumber --dry-run
    Then it should execute successfully
    And it should show the feature scenarios
