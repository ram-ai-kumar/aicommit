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
    Then the result should be empty

  Scenario: Exclude package-lock.json content
    Given a package-lock.json file is staged
    When I filter and truncate the diff
    Then lockfile content should be excluded
    And "lockfileVersion" should not appear in output

  Scenario: Exclude binary file diffs
    Given a PNG file is staged
    When I filter and truncate the diff
    Then "Binary files differ" should not appear in output

  Scenario: Exclude dist directory content
    Given files in dist/ directory are staged
    When I filter and truncate the diff
    Then minified content should be excluded

  Scenario: Truncate long markdown diffs at 20 lines
    Given a README.md with 40 lines of additions is staged
    When I filter and truncate the diff
    Then only 20 or fewer addition lines should remain
    And truncation notice should be added

  Scenario: Truncate long source code diffs at 80 lines
    Given a source file with 120 lines of additions is staged
    When I filter and truncate the diff
    Then only 80 or fewer addition lines should remain
    And truncation notice should be added

  Scenario: Handle files with spaces in names
    Given a file named "file with spaces.txt" is staged
    When I build file context
    Then the context should be built successfully
    And the file should be processed correctly

  Scenario: Handle files with special characters in names
    Given a file named "file-with-dashes_and_underscores.txt" is staged
    When I build file context
    Then the context should be built successfully
    And the file should be processed correctly

  Scenario: Handle very long file names
    Given a file with a very long name is staged
    When I build file context
    Then the context should be built successfully
    And file name should be handled properly

  Scenario: Handle files with Unicode characters
    Given a file with Unicode characters is staged
    When I build file context
    Then the context should be built successfully
    And Unicode should be preserved correctly

  Scenario: Handle empty files
    Given an empty file is staged
    When I build file context
    Then the context should be built successfully
    And empty file should be handled gracefully

  Scenario: Handle files with only whitespace
    Given a file with only whitespace is staged
    When I build file context
    Then the context should be built successfully
    And whitespace should be handled appropriately

  Scenario: Handle extremely large single line
    Given a file with extremely long line is staged
    When I filter and truncate the diff
    Then the line should be handled appropriately
    And truncation should work correctly

  Scenario: Handle files with many small changes
    Given a file with many small changes is staged
    When I filter and truncate the diff
    Then changes should be processed correctly
    And truncation should preserve important content

  Scenario: Handle mixed binary and text files
    Given both binary and text files are staged
    When I build file context
    Then text files should be processed
    And binary files should be excluded appropriately

  Scenario: Handle deeply nested directory structures
    Given files in deeply nested directories are staged
    When I build file context
    Then context should be built successfully
    And directory structure should be handled correctly

  Scenario: Handle files with similar names
    Given files with similar names are staged
    When I build file context
    Then each file should be processed distinctly
    And no confusion should occur

  Scenario: Handle files with no extensions
    Given files without extensions are staged
    When I build file context
    Then files should be processed correctly
    And missing extensions should be handled

  Scenario: Handle files with multiple extensions
    Given files with multiple extensions are staged
    When I build file context
    Then files should be processed correctly
    And multiple extensions should be handled

  Scenario: Handle files with uncommon extensions
    Given files with uncommon extensions are staged
    When I build file context
    Then files should be processed correctly
    And uncommon extensions should be handled

  Scenario: Handle files with executable permissions
    Given executable files are staged
    When I build file context
    Then files should be processed correctly
    And executable status should be noted

  Scenario: Handle files with read-only permissions
    Given read-only files are staged
    When I build file context
    Then files should be processed correctly
    And permission restrictions should be handled

  Scenario: Handle symlinks
    Given symbolic links are staged
    When I build file context
    Then symlinks should be handled appropriately
    And link targets should be processed correctly

  Scenario: Handle hard links
    Given hard links are staged
    When I build file context
    Then hard links should be handled appropriately
    And linked files should be processed correctly

  Scenario: Handle files with very old timestamps
    Given files with old timestamps are staged
    When I build file context
    Then files should be processed correctly
    And timestamp handling should work

  Scenario: Handle files with future timestamps
    Given files with future timestamps are staged
    When I build file context
    Then files should be processed correctly
    And timestamp anomalies should be handled

  Scenario: Handle files with unusual line endings
    Given files with unusual line endings are staged
    When I build file context
    Then line endings should be normalized
    And content should be processed correctly

  Scenario: Handle files with BOM (Byte Order Mark)
    Given files with BOM are staged
    When I build file context
    Then BOM should be handled appropriately
    And content should be processed correctly

  Scenario: Handle files with mixed line ending styles
    Given files with mixed line endings are staged
    When I build file context
    Then line endings should be normalized
    And content should be processed correctly

  Scenario: Count sensitive files but exclude content
    Given .env and normal files are staged
    When I build file context
    Then both files should be counted in file count
    And But .env content should be excluded from change stats

  Scenario: Detect project type with multiple indicators
    Given Gemfile, package.json, and requirements.txt exist
    When I detect project type
    Then the first matching type should be selected
    And "rails/ruby" should be returned

  Scenario: Analyze change concentration for single file
    Given only one file is changed
    When I analyze change concentration
    Then concentration should be 100 percent

  Scenario: Analyze change concentration across directories
    Given files are spread across multiple directories
    When I analyze change concentration
    Then concentration percentages should be calculated per directory
    And lib directory should show 50 percent for 2/4 files

  Scenario: Temporary directory path should not contain traversal
    When I get aicommit temporary directory
    Then the path should not contain ".."
    And the path should be safe

  Scenario: Categorize asset files correctly
    Given asset files like logo.png and banner.jpg are staged
    When I categorize staged files
    Then they should be categorized as "Static Assets"

  Scenario: Write asset files list when temp directory provided
    Given asset files are staged
    And a temporary directory is provided
    When I categorize staged files
    Then ASSET_FILES should be written to temp directory

  Scenario: Fallback model should include preferred model if available
    Given preferred model is available in model list
    When I search for fallback model
    Then preferred model should be returned
    And search should succeed

  Scenario: Fallback model should prioritize commit-specific models
    Given generic and commit-specific models are available
    When I search for fallback model
    Then commit-specific model should be preferred over generic

  Scenario: Handle model loadability timeout
    Given model takes too long to respond
    When I test model loadability
    Then the test should fail due to timeout

  Scenario: Handle malformed ollama output gracefully
    Given ollama returns invalid output structure
    When I list available models
    Then command should succeed
    And But output should be empty

  Scenario: Handle extremely long file names
    Given a file with very long name is staged
    When I build file context
    Then the file should be processed correctly
    And no buffer overflow should occur

  Scenario: Handle special characters in file names
    Given files with special characters in names are staged
    When I build file context
    Then files should be processed correctly
    And special characters should be handled properly

  Scenario: Handle Unicode content in files
    Given files with Unicode content are staged
    When I build file context
    Then Unicode content should be preserved
    And encoding should be handled correctly

  Scenario: Handle very large diff output
    Given a very large number of staged changes
    When I filter and truncate the diff
    Then processing should complete in reasonable time
    And memory usage should remain bounded

  Scenario: Handle zero-byte files
    Given empty files are staged
    When I build file context
    Then empty files should be handled correctly
    And no errors should occur

  Scenario: Handle files with only whitespace
    Given files containing only whitespace are staged
    When I build file context
    Then whitespace-only files should be handled correctly

  Scenario: Handle deeply nested directory structures
    Given files in deeply nested directories are staged
    When I build file context
    Then deep nesting should be handled correctly
    And path processing should work

  Scenario: Handle files with identical names in different directories
    Given files with same name in different directories are staged
    When I build file context
    Then each file should be handled distinctly
    And no conflicts should occur

  Scenario: Handle maximum git diff size
    Given git diff approaches maximum size limits
    When I process the diff
    Then processing should complete successfully
    And no truncation errors should occur

  Scenario: Handle concurrent access to temporary files
    Given multiple processes access temporary files
    When I build file context
    Then file access should be thread-safe
    And no corruption should occur

  Scenario: Handle disk space exhaustion
    Given disk space is running low
    When I create temporary files
    Then appropriate error should be raised
    And cleanup should be performed

  Scenario: Handle file permission issues
    Given staged files have unusual permissions
    When I build file context
    Then permission issues should be handled gracefully
    And processing should continue where possible
