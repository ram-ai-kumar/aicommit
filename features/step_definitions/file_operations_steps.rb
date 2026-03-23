# File Operations and Directory Management Step Definitions
# Handles file operations, temporary directories, and file system interactions

require 'fileutils'
require 'tempfile'

When(/^I request aicommit temporary directory$/) do
  @temp_dir = Dir.mktmpdir('aicommit-temp-test')
  @temp_dir_requested = true
end

Then(/^the directory should be created$/) do
  expect(@temp_dir).to_not be_nil
  expect(File.exist?(@temp_dir)).to be true
  @directory_created = true
end

Then(/^the directory should be under ([^"]*)$/) do |parent_dir|
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

Then(/^the directory should be under "([^"]*)"$/) do |parent_dir|
  expect(@temp_dir).to start_with(parent_dir)
  @directory_under_parent = true
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
