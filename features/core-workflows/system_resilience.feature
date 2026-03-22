@functional
Feature: AI Commit Exception Handling Tests
  As a developer using aicommit
  I want the system to handle exceptions gracefully
  So I can recover from errors and continue working

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Handle git command failures gracefully
    Given git commands are failing
    When I run aicommit
    And Then appropriate error message should be displayed
    And And cleanup should be performed
    And And exit code should indicate failure

  Scenario: Handle ollama service crashes
    Given ollama service crashes during operation
    When aicommit is processing a commit
    And Then operation should fail gracefully
    And And error should mention service unavailability
    And And temporary files should be cleaned up

  Scenario: Handle network connectivity issues
    Given network connectivity is lost
    When aicommit tries to communicate with ollama
    And Then operation should timeout appropriately
    And And error should mention connectivity issues
    And And user should be informed of retry options

  Scenario: Handle insufficient disk space
    Given disk space is insufficient for temporary files
    When I run aicommit
    And Then operation should fail with clear error
    And And error should mention disk space
    And And no partial files should be left behind

  Scenario: Handle permission denied errors
    Given file permissions prevent temporary file creation
    When I run aicommit
    And Then operation should fail with permission error
    And And error should suggest solutions
    And And cleanup should be attempted

  Scenario: Handle memory exhaustion scenarios
    Given system memory is exhausted
    When aicommit processes large diffs
    And Then operation should fail gracefully
    And And error should mention memory constraints
    And And system should remain stable

  Scenario: Handle corrupted git repository
    Given git repository is corrupted
    When I run aicommit
    And Then operation should fail with git error
    And And error should suggest git repository repair
    And And no further damage should occur

  Scenario: Handle interrupted processes
    Given aicommit process is interrupted
    When cleanup is performed
    And Then temporary files should be removed
    And And git state should remain consistent
    And And no locks should remain

  Scenario: Handle malformed configuration files
    Given configuration files contain syntax errors
    When aicommit loads configuration
    And Then default values should be used
    And And warning should be displayed
    And And operation should continue

  Scenario: Handle missing required dependencies
    Given required commands are not available
    When I run aicommit
    And Then clear error should be displayed
    And And installation instructions should be provided
    And And operation should fail gracefully

  Scenario: Handle timeout during model loading
    Given model loading takes too long
    When aicommit tries to load a model
    And Then timeout should occur
    And And error should mention timeout
    And And fallback options should be suggested

  Scenario: Handle invalid model responses
    Given ollama returns invalid JSON response
    When aicommit processes the response
    And Then response should be rejected
    And And error should mention invalid response
    And And operation should fail gracefully

  Scenario: Handle concurrent aicommit instances
    Given another aicommit instance is running
    When I try to run aicommit
    And Then appropriate warning should be displayed
    And And operation should wait or fail gracefully
    And And no corruption should occur

  Scenario: Handle signal interruption during critical operations
    Given SIGINT is received during commit processing
    When signal handling occurs
    And Then cleanup should be performed
    And And git state should be consistent
    And And user should be informed

  Scenario: Handle filesystem read-only scenarios
    Given filesystem becomes read-only
    When aicommit tries to write temporary files
    And Then operation should fail gracefully
    And And error should mention read-only filesystem
    And And cleanup should be attempted

  Scenario: Handle corrupted model files
    Given model files are corrupted
    When aicommit tries to use the model
    And Then operation should fail gracefully
    And And error should mention model corruption
    And And alternative models should be suggested

  Scenario: Handle excessive input size
    Given input size exceeds reasonable limits
    When aicommit processes the input
    And Then input should be truncated appropriately
    And And warning should be displayed
    And And operation should continue

  Scenario: Handle malformed git diff output
    Given git diff returns malformed output
    When aicommit processes the diff
    And Then error should be handled gracefully
    And And processing should continue with available data
    And And user should be warned

  Scenario: Handle database lock acquisition failures
    Given database locks cannot be acquired
    When aicommit tries to access resources
    And Then operation should fail gracefully
    And And error should mention lock issues
    And And retry should be suggested

  Scenario: Handle environment variable overflow
    Given environment variables are too large
    When aicommit reads configuration
    And Then variables should be truncated or rejected
    And And warning should be displayed
    And And defaults should be used

  Scenario: Handle pipe buffer overflow
    Given pipe buffer overflows during processing
    When aicommit processes large data
    And Then overflow should be detected
    And And data should be processed in chunks
    And And operation should complete successfully

  Scenario: Handle zombie process cleanup
    Given zombie processes are created
    When aicommit completes operations
    And Then zombie processes should be cleaned up
    And And system resources should be freed
    And And no leaks should remain

  Scenario: Handle stack overflow in recursive operations
    Given recursive operations risk stack overflow
    When aicommit processes deep structures
    And Then recursion should be limited
    And And iteration should be used instead
    And And operation should complete

  Scenario: Handle floating point exceptions
    Given floating point operations may overflow
    When aicommit performs calculations
    And Then exceptions should be caught
    And And appropriate defaults should be used
    And And operation should continue

  Scenario: Handle integer overflow scenarios
    Given integer calculations may overflow
    When aicommit performs arithmetic
    And Then overflow should be detected
    And And appropriate limits should be enforced
    And And operation should handle gracefully

  Scenario: Handle null pointer dereferences
    Given null values may be encountered
    When aicommit processes data
    And Then null checks should be performed
    And And safe defaults should be used
    And And crashes should be prevented

  Scenario: Handle array index out of bounds
    Given array access may exceed bounds
    When aicommit processes arrays
    And Then bounds checking should be performed
    And And safe access should be ensured
    And And errors should be handled gracefully
