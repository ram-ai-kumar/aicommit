@functional @performance @stage2
Feature: AI Commit Performance and Scalability Testing
  As a developer using aicommit
  I want system to perform well under various load conditions
  So I can rely on it for both small and large-scale projects

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Large repository handling with 1000+ files
    Given repository contains over 1000 files
    And I have made changes to multiple files
    When I run aicommit command "--dry-run"
    Then processing should complete within reasonable time
    And memory usage should remain within limits
    And a commit message should be generated
    And performance should be acceptable for large repos

  Scenario: Concurrent processing testing
    Given multiple aicommit processes run simultaneously
    And I have made changes to multiple files
    When I run aicommit command "--dry-run"
    Then concurrent access should be detected
    And lock mechanism should prevent conflicts
    And the command should succeed
    And overall performance should remain stable

  Scenario: Memory usage validation under load
    Given system has limited available memory
    And I have made large changes requiring processing
    When I run aicommit command "--dry-run"
    Then memory constraints should be detected
    And processing should be optimized for low memory
    And large changes should be processed in chunks
    And the command should succeed
    And user should be informed about memory usage

  Scenario: CPU usage optimization testing
    Given system has limited CPU resources
    And I have made complex changes
    When I run aicommit command "--dry-run"
    Then CPU usage should be optimized
    And processing should complete efficiently
    And system responsiveness should be maintained
    And the command should succeed

  Scenario: Disk I/O performance validation
    Given disk I/O is slow
    And I have made many file changes
    When I run aicommit command "--dry-run"
    Then disk operations should be optimized
    And temporary file usage should be efficient
    And processing should complete despite slow I/O
    And the command should succeed
    And user should be informed about I/O constraints

  Scenario: Network bandwidth optimization
    Given network bandwidth is limited
    And ollama backend is configured
    And I have made changes to multiple files
    When I run aicommit command "--dry-run"
    Then network usage should be optimized
    And requests should be batched appropriately
    And processing should complete within bandwidth limits
    And the command should succeed
    And user should be informed about network optimization

  Scenario: Cache performance testing
    Given aicommit cache is being used
    And I have made repeated similar changes
    When I run aicommit command "--dry-run"
    Then cache should improve performance
    And cache hits should be measured
    And cache misses should be minimized
    And overall processing should be faster
    And the command should succeed

  Scenario: Scalability with increasing file counts
    Given repository contains over 1000 files
    And I have made changes to multiple files
    When I run aicommit command "--dry-run" with different loads
    Then performance should scale linearly
    And processing time should grow proportionally
    And resource usage should remain predictable
    And system should handle maximum expected load
    And the command should succeed

  Scenario: Performance regression detection
    Given baseline performance metrics are established
    And I have made standard changes
    When I run aicommit command "--dry-run"
    Then current performance should be compared to baseline
    And regressions should be detected
    And performance alerts should be triggered if needed
    And user should be informed about performance issues
    And the command should succeed

  Scenario: Resource cleanup verification
    Given aicommit has processed large changes
    And temporary files were created
    When processing completes
    Then all temporary files should be cleaned up
    And memory should be released
    And no resource leaks should occur
    And system should return to clean state
    And the command should succeed

  Scenario: Performance under different system loads
    Given system has varying background load
    And I have made changes to files
    When I run aicommit command "--dry-run"
    Then performance should adapt to system load
    And processing should complete successfully
    And priority should be given to aicommit processing
    And system responsiveness should be maintained
    And the command should succeed

  Scenario: Database performance optimization
    Given aicommit uses database for caching
    And I have made many changes
    When I run aicommit command "--dry-run"
    Then database operations should be optimized
    And queries should be efficient
    And transactions should be batched
    And database performance should not be bottleneck
    And the command should succeed

  Scenario: Parallel processing capabilities
    Given multiple files can be processed independently
    And I have made changes to many files
    When I run aicommit command "--dry-run"
    Then files should be processed in parallel where possible
    And parallel processing should improve performance
    And thread safety should be maintained
    And results should be consistent
    And the command should succeed

  Scenario: Performance monitoring and reporting
    Given performance monitoring is enabled
    And I have made changes to files
    When I run aicommit command "--dry-run"
    Then performance metrics should be collected
    And timing data should be accurate
    And resource usage should be tracked
    And performance report should be available
    And the command should succeed

  Scenario: Handle git command failures gracefully
    Given git commands are failing
    When I run aicommit
    Then appropriate error message should be displayed
    And cleanup should be performed
    And exit code should indicate failure

  Scenario: Handle ollama service crashes
    Given ollama service crashes during operation
    When aicommit is processing a commit
    Then operation should fail gracefully
    And error should mention service unavailability
    And temporary files should be cleaned up

  Scenario: Handle network connectivity issues
    Given network connectivity is lost
    When aicommit tries to communicate with ollama
    Then operation should timeout appropriately
    And error should mention connectivity issues
    And user should be informed of retry options

  Scenario: Handle insufficient disk space
    Given disk space is insufficient for temporary files
    When I run aicommit
    Then operation should fail with clear error
    And error should mention disk space
    And no partial files should be left behind

  Scenario: Handle permission denied errors
    Given file permissions prevent temporary file creation
    When I run aicommit
    Then operation should fail with permission error
    And error should suggest solutions
    And cleanup should be attempted

  Scenario: Handle memory exhaustion scenarios
    Given system memory is exhausted
    When aicommit processes large diffs
    Then operation should fail gracefully
    And error should mention memory constraints
    And system should remain stable

  Scenario: Handle corrupted git repository
    Given git repository is corrupted
    When I run aicommit
    Then operation should fail with git error
    And error should suggest git repository repair
    And no further damage should occur

  Scenario: Handle interrupted processes
    Given aicommit process is interrupted
    When cleanup is performed
    Then temporary files should be removed
    And git state should remain consistent
    And no locks should remain

  Scenario: Handle malformed configuration files
    Given configuration files contain syntax errors
    When aicommit loads configuration
    Then default values should be used
    And warning should be displayed
    And operation should continue

  Scenario: Handle missing required dependencies
    Given required commands are not available
    When I run aicommit
    Then clear error should be displayed
    And installation instructions should be provided
    And operation should fail gracefully

  Scenario: Handle timeout during model loading
    Given model loading takes too long
    When aicommit tries to load a model
    Then timeout should occur
    And error should mention timeout
    And fallback options should be suggested

  Scenario: Handle invalid model responses
    Given ollama returns invalid JSON response
    When aicommit processes the response
    Then response should be rejected
    And error should mention invalid response
    And operation should fail gracefully

  Scenario: Handle concurrent aicommit instances
    Given another aicommit instance is running
    When I try to run aicommit
    Then appropriate warning should be displayed
    And operation should wait or fail gracefully
    And no corruption should occur

  Scenario: Handle signal interruption during critical operations
    Given SIGINT is received during commit processing
    When signal handling occurs
    Then cleanup should be performed
    And git state should be consistent
    And user should be informed

  Scenario: Handle filesystem read-only scenarios
    Given filesystem becomes read-only
    When aicommit tries to write temporary files
    Then operation should fail gracefully
    And error should mention read-only filesystem
    And cleanup should be attempted

  Scenario: Handle corrupted model files
    Given model files are corrupted
    When aicommit tries to use the model
    Then operation should fail gracefully
    And error should mention model corruption
    And alternative models should be suggested

  Scenario: Handle excessive input size
    Given input size exceeds reasonable limits
    When aicommit processes the input
    Then input should be truncated appropriately
    And warning should be displayed
    And operation should continue

  Scenario: Handle malformed git diff output
    Given git diff returns malformed output
    When aicommit processes the diff
    Then error should be handled gracefully
    And processing should continue with available data
    And user should be warned

  Scenario: Handle database lock acquisition failures
    Given database locks cannot be acquired
    When aicommit tries to access resources
    Then operation should fail gracefully
    And error should mention lock issues
    And retry should be suggested

  Scenario: Handle environment variable overflow
    Given environment variables are too large
    When aicommit reads configuration
    Then variables should be truncated or rejected
    And warning should be displayed
    And defaults should be used

  Scenario: Handle pipe buffer overflow
    Given pipe buffer overflows during processing
    When aicommit processes large data
    Then overflow should be detected
    And data should be processed in chunks
    And operation should complete successfully

  Scenario: Handle zombie process cleanup
    Given zombie processes are created
    When aicommit completes operations
    Then zombie processes should be cleaned up
    And system resources should be freed
    And no leaks should remain

  Scenario: Handle stack overflow in recursive operations
    Given recursive operations risk stack overflow
    When aicommit processes deep structures
    Then recursion should be limited
    And iteration should be used instead
    And operation should complete

  Scenario: Handle floating point exceptions
    Given floating point operations may overflow
    When aicommit performs calculations
    Then exceptions should be caught
    And appropriate defaults should be used
    And operation should continue

  Scenario: Handle integer overflow scenarios
    Given integer calculations may overflow
    When aicommit performs arithmetic
    Then overflow should be detected
    And appropriate limits should be enforced
    And operation should handle gracefully

  Scenario: Handle null pointer dereferences
    Given null values may be encountered
    When aicommit processes data
    Then null checks should be performed
    And safe defaults should be used
    And crashes should be prevented

  Scenario: Handle array index out of bounds
    Given array access may exceed bounds
    When aicommit processes arrays
    Then bounds checking should be performed
    And safe access should be ensured
    And errors should be handled gracefully
