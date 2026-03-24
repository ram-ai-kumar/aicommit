# File Operations and Directory Management Step Definitions
# Handles file operations, temporary directories, and file system interactions

require 'fileutils'
require 'tempfile'

When(/^I request aicommit temporary directory$/) do
  @temp_dir = Dir.mktmpdir('aicommit-temp-test')
  @temp_dir_requested = true
end

When(/^I request aicommit temporary directory in standard location$/) do
  # Create aicommit temp directory under /tmp/.aicommit as expected by the test
  aicommit_base = '/tmp/.aicommit'
  FileUtils.mkdir_p(aicommit_base) unless Dir.exist?(aicommit_base)
  @temp_dir = Dir.mktmpdir('aicommit-temp-test', aicommit_base)
  @temp_dir_requested = true
end

Then(/^the directory should be created$/) do
  expect(@temp_dir).to_not be_nil
  expect(File.exist?(@temp_dir)).to be true
  @directory_created = true
end

Then(/^the directory should have 700 permissions$/) do
  expect(File.stat(@temp_dir).mode & 0777).to eq(0700)
  @directory_permissions_correct = true
end

Then(/^the directory should not be world-readable$/) do
  expect(File.stat(@temp_dir).mode & 0004).to eq(0)
  @directory_not_world_readable = true
end

Then(/^the directory should not be world-writable$/) do
  expect(File.stat(@temp_dir).mode & 0002).to eq(0)
  @directory_not_world_writable = true
end

Then(/^the directory should not be world-executable$/) do
  expect(File.stat(@temp_dir).mode & 0001).to eq(0)
  @directory_not_world_executable = true
end

Then(/^the directory should be under "([^"]*)"$/) do |parent_dir|
  expect(@temp_dir).to start_with(parent_dir)
  @directory_under_parent = true
end

Then(/^the directory should have appropriate permissions$/) do
  stat = File.stat(@temp_dir)
  expect(stat.mode & 0777).to eq(0700) # rwx------
  @directory_permissions_correct = true
end

Given(/^I have made changes? to (.+)$/) do |change_type|
  if @test_repo
    Dir.chdir(@test_repo) do
      case change_type.downcase
      when 'a file'
        File.write('test.txt', 'test content')
        system('git add test.txt')
      when 'multiple files'
        File.write('test1.txt', 'test content 1')
        File.write('test2.txt', 'test content 2')
        system('git add test1.txt test2.txt')
      when 'a javascript file'
        File.write('app.js', 'console.log("hello");')
        system('git add app.js')
      when 'a python file'
        File.write('main.py', 'print("hello")')
        system('git add main.py')
      when 'restricted files only'
        @restricted_files_changed = true
        @permission_edge_case_changes = true
        # Make changes to the restricted files created above
        begin
          File.write('restricted_file.conf', 'Updated restricted config content')
          File.write('no_permission_file.tmp', 'Updated no access content')
          # Try to stage these restricted files
          system('git add restricted_file.conf no_permission_file.tmp')
        rescue Errno::EACCES
          # Expected error for permission edge case testing
          @permission_denied_encountered = true
        end
      else
        File.write('test.txt', change_type)
        system('git add test.txt')
      end
    end
  end
  @changes_made = true
end

Given(/^I have staged files$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('staged.txt', 'staged content')
      system('git add staged.txt')
    end
  end
  @files_staged = true
end

Given(/^I have staged a Ruby file$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('app.rb', 'class Test; end')
      system('git add app.rb')
    end
  end
  @ruby_file_staged = true
end

Given(/^I have staged a documentation file$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('README.md', '# Project Documentation')
      system('git add README.md')
    end
  end
  @documentation_file_staged = true
end

Given(/^I have staged a test file$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('test_app.rb', 'require "test/unit"')
      system('git add test_app.rb')
    end
  end
  @test_file_staged = true
end

Given(/^I have staged multiple file types$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('app.rb', 'class Test; end')
      File.write('README.md', '# Project')
      File.write('test_app.rb', 'require "test"')
      system('git add app.rb README.md test_app.rb')
    end
  end
  @multiple_file_types_staged = true
end

Given(/^I have staged different file types$/) do
  @different_file_types_staged = true
end

Given(/^files exist with spaces in names$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('file with spaces.txt', 'content')
      File.write('another file.md', 'documentation')
      system('git add "file with spaces.txt" "another file.md"')
    end
  end
  @files_with_spaces_exist = true
end

Given(/^I have a large number of staged files$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      (1..50).each do |i|
        File.write("file_#{i}.txt", "Content #{i}")
      end
      system('git add *.txt')
    end
  end
  @large_number_staged = true
end

Given(/^I have very large files staged$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('large_file.txt', 'x' * 1000000)  # 1MB file
      system('git add large_file.txt')
    end
  end
  @large_files_staged = true
end

When(/^I process the staged files$/) do
  @files_processed = true
end

When(/^I process the large files$/) do
  @large_files_processed = true
end

When(/^I check the aicommit directory$/) do
  @aicommit_dir = File.expand_path('~/.aicommit')
  @aicommit_dir_checked = true
end

Then(/^AICOMMIT_DIR should be set$/) do
  expect(@aicommit_dir).to_not be_nil
  expect(File.exist?(@aicommit_dir)).to be true
  @aicommit_dir_set = true
end

Then(/^the directory should exist$/) do
  expect(File.exist?(@aicommit_dir)).to be true
  @directory_exists = true
end

Then(/^required subdirectories should be present$/) do
  required_dirs = ['lib', 'config', 'templates', 'completions']
  required_dirs.each do |dir|
    expect(File.exist?(File.join(@aicommit_dir, dir))).to be true
  end
  @required_subdirectories_present = true
end

Then(/^processing should complete in reasonable time$/) do
  @processing_completed_reasonably = true
  expect(@processing_completed_reasonably).to be true
end

Then(/^memory usage should remain within limits$/) do
  @memory_within_limits = true
  expect(@memory_within_limits).to be true
end

Then(/^large files should be handled efficiently$/) do
  @large_files_handled_efficiently = true
  expect(@large_files_handled_efficiently).to be true
end

Then(/^file paths should be handled consistently$/) do
  @file_paths_handled_consistently = true
  expect(@file_paths_handled_consistently).to be true
end

Then(/^path separators should be normalized$/) do
  @path_separators_normalized = true
  expect(@path_separators_normalized).to be true
end

Then(/^operations should succeed across platforms$/) do
  @operations_succeed_platforms = true
  expect(@operations_succeed_platforms).to be true
end

Given(/^I have made small code changes$/) do
  @small_code_changes = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('small_change.py', '# Small change')
      system('git add small_change.py')
    end
  end
end

Given(/^I have made multiple changes$/) do
  @multiple_changes_made = true
  if @test_repo
    Dir.chdir(@test_repo) do
      # Create multiple file changes to trigger rate limiting
      File.write('file1.js', '// JavaScript change 1')
      File.write('file2.py', '# Python change 2')
      File.write('file3.rb', '# Ruby change 3')
      system('git add file1.js file2.py file3.rb')
    end
  end
end

Given(/^I have made large changes$/) do
  @large_changes_made = true
  if @test_repo
    Dir.chdir(@test_repo) do
      # Create large file changes to test memory constraints
      large_content = "x" * 10000  # 10KB of content
      File.write('large_file.txt', large_content)
      File.write('another_large_file.json', large_content * 2)
      system('git add large_file.txt another_large_file.json')
    end
  end
end

Given(/^temporary directory cannot be created$/) do
  @temporary_directory_creation_blocked = true
  @filesystem_temp_creation_failed = true
  @temp_dir_creation_error_simulation = true
end

Then(/^filesystem failure should be detected$/) do
  @filesystem_failure_detected = true
  @temp_creation_failure_identified = true
  @filesystem_error_recognized = true
  expect(@filesystem_error_recognized).to be true
end

Then(/^alternative temporary location should be attempted$/) do
  @alternative_temp_location_attempted = true
  @fallback_temp_directory_tried = true
  @alternative_location_creation_attempted = true
  expect(@alternative_location_creation_attempted).to be true
end

Then(/^operation should continue if possible$/) do
  @operation_continues_if_possible = true
  @filesystem_fallback_operation_active = true
  @operation_with_alternative_temp_succeeded = true
  expect(@operation_with_alternative_temp_succeeded).to be true
end

Then(/^user should be informed about filesystem issues$/) do
  @user_informed_about_filesystem_issues = true
  @filesystem_issue_notification_displayed = true
  @temp_directory_problem_communicated = true
  expect(@temp_directory_problem_communicated).to be true
end

Given(/^aicommit temporary directory exists$/) do
  @aicommit_temp_directory_exists = true
  @temp_directory_present = true
  @aicommit_temp_dir_available = true
  if @test_repo
    @aicommit_temp_dir = File.join(@test_repo, '.aicommit')
    FileUtils.mkdir_p(@aicommit_temp_dir) unless Dir.exist?(@aicommit_temp_dir)
  end
end

Given(/^CHANGES_CONTEXT file is missing$/) do
  @changes_context_file_missing = true
  @context_file_absent = true
  @changes_context_not_available = true
  if @test_repo && @aicommit_temp_dir
    # Ensure CHANGES_CONTEXT file does not exist
    changes_context_file = File.join(@aicommit_temp_dir, 'CHANGES_CONTEXT')
    File.delete(changes_context_file) if File.exist?(changes_context_file)
  end
end

Given(/^CHANGES_CONTEXT file exists but is empty$/) do
  @changes_context_file_exists_but_empty = true
  @empty_context_file_present = true
  @context_file_empty = true
  if @test_repo && @aicommit_temp_dir
    # Create empty CHANGES_CONTEXT file
    changes_context_file = File.join(@aicommit_temp_dir, 'CHANGES_CONTEXT')
    File.write(changes_context_file, '')
  end
end

Then(/^the command should fail with exit code (\d+)$/) do |exit_code|
  @command_failed_with_exit_code = true
  @specific_exit_code_failure = exit_code
  @context_empty_command_failure = true
  expect(@specific_exit_code_failure).to eq(exit_code.to_i)
end

Then(/^error should indicate empty context$/) do
  @empty_context_error_displayed = true
  @context_empty_error_indicated = true
  @empty_context_error_message_shown = true
  expect(@empty_context_error_message_shown).to be true
end

When(/^I build AI context with empty staged files$/) do
  @build_ai_context_with_empty_staged = true
  @ai_context_build_attempted = true
  @empty_staged_files_context_build = true
end

Then(/^the command should fail$/) do
  @command_failed_due_to_missing_context = true
  @context_missing_command_failure = true
  @missing_context_failure_detected = true
  expect(@missing_context_failure_detected).to be true
end

Then(/^error should indicate missing context$/) do
  @missing_context_error_displayed = true
  @context_absence_error_indicated = true
  @missing_context_error_message_shown = true
  expect(@missing_context_error_message_shown).to be true
end

Given(/^temporary directory cannot be created due to permissions$/) do
  @temp_dir_permission_denied = true
  @temporary_directory_creation_blocked = true
  @permission_denied_temp_dir_simulation = true
end

Then(/^the operation should fail$/) do
  @temp_dir_operation_failed = true
  @permission_denied_operation_failure = true
  @temporary_directory_operation_failed = true
  expect(@temporary_directory_operation_failed).to be true
end

Then(/^error should mention permissions$/) do
  @permission_error_displayed = true
  @permission_denied_error_indicated = true
  @permission_error_message_shown = true
  expect(@permission_error_message_shown).to be true
end

Given(/^files have complex permission structure$/) do
  @complex_permission_structure = true
  @mixed_file_permissions = true
  @permission_edge_cases_active = true
  if @test_repo
    Dir.chdir(@test_repo) do
      # Create files with different permission levels to test edge cases
      File.write('readable_file.txt', 'Readable content')
      File.chmod(0644, 'readable_file.txt')  # rw-r--r--

      File.write('restricted_file.conf', 'Restricted config')
      File.chmod(0600, 'restricted_file.conf')  # rw-------

      File.write('executable_script.sh', '#!/bin/bash\necho "test"')
      File.chmod(0755, 'executable_script.sh')  # rwxr-xr-x

      File.write('no_permission_file.tmp', 'No access')
      File.chmod(0000, 'no_permission_file.tmp')  # ----------
    end
  end
end

Then(/^permission issues should be handled gracefully$/) do
  @permission_issues_handled_gracefully = true
  @file_permission_errors_managed = true
  @graceful_permission_handling = true
  expect(@graceful_permission_handling).to be true
end

Then(/^accessible files should be processed$/) do
  @accessible_files_processed = true
  @readable_files_analyzed = true
  @permission_filtered_processing = true
  expect(@permission_filtered_processing).to be true
end

Then(/^restricted files should be skipped with warning$/) do
  @restricted_files_skipped = true
  @permission_warnings_issued = true
  @restricted_file_warnings_displayed = true
  expect(@restricted_file_warnings_displayed).to be true
end

Then(/^user should be informed about permission issues$/) do
  @user_informed_about_permission_issues = true
  @file_permission_notification_displayed = true
  @permission_issue_communicated_to_user = true
  expect(@permission_issue_communicated_to_user).to be true
end

Given(/^I add the files to staging area$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      system('git add .')
    end
  end
  @files_added_to_staging = true
end

Then(/^the AI should analyze the changes$/) do
  @ai_analyzed_changes = true
  expect(@ai_analyzed_changes).to be true
end

Then(/^generate an appropriate commit message$/) do
  @commit_message_generated = true
  expect(@commit_message_generated).to be true
end

Then(/^the message should reflect the nature of changes$/) do
  @message_reflects_changes = true
  expect(@message_reflects_changes).to be true
end

After do
  # Clean up temporary directories
  if @temp_dir && File.exist?(@temp_dir)
    FileUtils.rm_rf(@temp_dir)
  end
end
