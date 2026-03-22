@functional
Feature: AI Commit Edge Case Tests
  As a developer using aicommit
  I want the system to handle boundary conditions and extreme inputs
  So I can rely on it in unusual but valid scenarios

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Handle completely empty diff input
    When I filter and truncate an empty diff
    And Then the result should be empty

  Scenario: Exclude package-lock.json content
    Given a package-lock.json file is staged
    When I filter and truncate the diff
    And Then lockfile content should be excluded
    And And "lockfileVersion" should not appear in output

  Scenario: Exclude binary file diffs
    Given a PNG file is staged
    When I filter and truncate the diff
    And Then "Binary files differ" should not appear in output

  Scenario: Exclude dist directory content
    Given files in dist/ directory are staged
    When I filter and truncate the diff
    And Then minified content should be excluded

  Scenario: Truncate long markdown diffs at 20 lines
    Given a README.md with 40 lines of additions is staged
    When I filter and truncate the diff
    And Then only 20 or fewer addition lines should remain
    And And truncation notice should be added

  Scenario: Truncate long source code diffs at 80 lines
    Given a source file with 120 lines of additions is staged
    When I filter and truncate the diff
    And Then only 80 or fewer addition lines should remain
    And And truncation notice should be added

  Scenario: Handle files with spaces in names
    Given a file named "file with spaces.txt" is staged
    When I build file context
    And Then the context should be built successfully
    And And the file should be processed correctly

  Scenario: Count sensitive files but exclude content
    Given .env and normal files are staged
    When I build file context
    And Then both files should be counted in file count
    And But .env content should be excluded from change stats

  Scenario: Detect project type with multiple indicators
    Given Gemfile, package.json, and requirements.txt exist
    When I detect project type
    And Then the first matching type should be selected
    And And "rails/ruby" should be returned

  Scenario: Analyze change concentration for single file
    Given only one file is changed
    When I analyze change concentration
    And Then concentration should be 100 percent

  Scenario: Analyze change concentration across directories
    Given files are spread across multiple directories
    When I analyze change concentration
    And Then concentration percentages should be calculated per directory
    And And lib directory should show 50 percent for 2/4 files

  Scenario: Temporary directory path should not contain traversal
    When I get aicommit temporary directory
    And Then the path should not contain ".."
    And And the path should be safe

  Scenario: Categorize asset files correctly
    Given asset files like logo.png and banner.jpg are staged
    When I categorize staged files
    And Then they should be categorized as "Static Assets"

  Scenario: Write asset files list when temp directory provided
    Given asset files are staged
    And a temporary directory is provided
    When I categorize staged files
    And Then ASSET_FILES should be written to temp directory

  Scenario: Fallback model should include preferred model if available
    Given preferred model is available in model list
    When I search for fallback model
    And Then preferred model should be returned
    And And search should succeed

  Scenario: Fallback model should prioritize commit-specific models
    Given generic and commit-specific models are available
    When I search for fallback model
    And Then commit-specific model should be preferred over generic

  Scenario: Handle model loadability timeout
    Given model takes too long to respond
    When I test model loadability
    And Then the test should fail due to timeout

  Scenario: Handle malformed ollama output gracefully
    Given ollama returns invalid output structure
    When I list available models
    And Then command should succeed
    And But output should be empty

  Scenario: Handle extremely long file names
    Given a file with very long name is staged
    When I build file context
    And Then the file should be processed correctly
    And And no buffer overflow should occur

  Scenario: Handle special characters in file names
    Given files with special characters in names are staged
    When I build file context
    And Then files should be processed correctly
    And And special characters should be handled properly

  Scenario: Handle Unicode content in files
    Given files with Unicode content are staged
    When I build file context
    And Then Unicode content should be preserved
    And And encoding should be handled correctly

  Scenario: Handle very large diff output
    Given a very large number of staged changes
    When I filter and truncate the diff
    And Then processing should complete in reasonable time
    And And memory usage should remain bounded

  Scenario: Handle zero-byte files
    Given empty files are staged
    When I build file context
    And Then empty files should be handled correctly
    And And no errors should occur

  Scenario: Handle files with only whitespace
    Given files containing only whitespace are staged
    When I build file context
    And Then whitespace-only files should be handled correctly

  Scenario: Handle deeply nested directory structures
    Given files in deeply nested directories are staged
    When I build file context
    And Then deep nesting should be handled correctly
    And And path processing should work

  Scenario: Handle files with identical names in different directories
    Given files with same name in different directories are staged
    When I build file context
    And Then each file should be handled distinctly
    And And no conflicts should occur

  Scenario: Handle maximum git diff size
    Given git diff approaches maximum size limits
    When I process the diff
    And Then processing should complete successfully
    And And no truncation errors should occur

  Scenario: Handle concurrent access to temporary files
    Given multiple processes access temporary files
    When I build file context
    And Then file access should be thread-safe
    And And no corruption should occur

  Scenario: Handle disk space exhaustion
    Given disk space is running low
    When I create temporary files
    And Then appropriate error should be raised
    And And cleanup should be performed

  Scenario: Handle file permission issues
    Given staged files have unusual permissions
    When I build file context
    And Then permission issues should be handled gracefully
    And And processing should continue where possible
