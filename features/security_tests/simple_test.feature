Feature: Simple Test
  As a developer
  I want to verify Cucumber setup is working
  So that I can run BDD tests

  Scenario: Basic Cucumber functionality test
    Given I have a working aicommit installation
    When I run cucumber --dry-run
    And Then it should execute successfully
