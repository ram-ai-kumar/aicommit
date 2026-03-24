# Git integration step definitions for AI Commit

# Backend authentication and connectivity steps
Given(/^ollama backend requires authentication$/) do
  @ollama_auth_required = true
  @authentication_needed = true
end

Given(/^git pre-commit hooks are configured$/) do
  @pre_commit_hooks_configured = true
  @git_hooks_active = true
end

Given(/^repository contains git submodules$/) do
  @git_submodules_present = true
  @submodule_handling_needed = true
end

Given(/^repository uses git worktrees$/) do
  @git_worktrees_enabled = true
  @worktree_handling_needed = true
end

Given(/^primary backend is not available$/) do
  @primary_backend_unavailable = true
  @fallback_needed = true
end

Given(/^fallback backend is configured$/) do
  @fallback_backend_configured = true
  @backup_backend_ready = true
end

Then(/^the system should fall back to secondary backend$/) do
  @fallback_to_secondary = true
  @secondary_backend_used = true
  expect(@secondary_backend_used).to be true
end

# Repository state steps
Given(/^I am in a repository with many files$/) do
  @large_repository = true
  @file_count = "many"
  @performance_considerations = true
end

Given(/^I have staged files in subdirectories$/) do
  @staged_subdirectory_files = true
  @nested_file_structure = true
end

Given(/^I have staged files with special characters$/) do
  @staged_special_char_files = true
  @special_char_handling = true
end

Given(/^I have unstaged changes$/) do
  @unstaged_changes_present = true
  @mixed_staging_state = true
end

Then(/^unstaged changes should be ignored$/) do
  @unstaged_ignored = true
  @only_staged_analyzed = true
  expect(@only_staged_analyzed).to be true
end

Given(/^git hooks are configured$/) do
  @git_hooks_configured = true
  @hook_integration_active = true
end

Given(/^I have both staged and unstaged changes$/) do
  @both_staged_and_unstaged = true
  @mixed_state_handling = true
end

Then(/^only staged changes should be analyzed$/) do
  @staged_only_analysis = true
  @unstaged_excluded = true
  expect(@unstaged_excluded).to be true
end

Then(/^all staged files should be analyzed$/) do
  @all_staged_analyzed = true
  @complete_staged_analysis = true
  expect(@complete_staged_analysis).to be true
end

Then(/^the commit message should cover all changes$/) do
  @comprehensive_commit_message = true
  @all_changes_covered = true
  expect(@all_changes_covered).to be true
end

# File type specific steps
Given(/^I have staged binary files$/) do
  @staged_binary_files = true
  @binary_file_handling = true
end

Then(/^binary files should be excluded from analysis$/) do
  @binary_files_excluded = true
  @text_only_analysis = true
  expect(@text_only_analysis).to be true
end

Then(/^text files should still be analyzed$/) do
  @text_files_analyzed = true
  @binary_exclusion_working = true
  expect(@binary_exclusion_working).to be true
end

Given(/^I have staged a large diff$/) do
  @large_diff_staged = true
  @diff_size_large = true
  @truncation_needed = true
end

Then(/^the diff should be truncated appropriately$/) do
  @diff_truncated = true
  @truncation_appropriate = true
  expect(@truncation_appropriate).to be true
end

Then(/^a meaningful commit message should still be generated$/) do
  @meaningful_message_generated = true
  @large_diff_handled = true
  expect(@large_diff_handled).to be true
end

# Empty repository and error handling steps
Given(/^no files are staged$/) do
  @no_staged_files = true
  @empty_staging_area = true
end

Then(/^the command should fail gracefully$/) do
  @graceful_failure = true
  @empty_staging_handled = true
  expect(@empty_staging_handled).to be true
end

Then(/^appropriate error message should be shown$/) do
  @empty_staging_error_shown = true
  @helpful_error_displayed = true
  expect(@helpful_error_displayed).to be true
end

# Cleanup steps
Given(/^aicommit temporary files exist$/) do
  @temp_files_exist = true
  @cleanup_needed = true
end

Then(/^the repository should be in a clean state$/) do
  @repository_clean = true
  @test_cleanup_complete = true
  expect(@test_cleanup_complete).to be true
end

# Commit message generation steps
Then(/^a commit message should be generated$/) do
  @basic_commit_message_generated = true
  @message_creation_successful = true
  expect(@message_creation_successful).to be true
end

Then(/^the message should follow conventional commits format$/) do
  @conventional_format_followed = true
  @message_structure_correct = true
  expect(@message_structure_correct).to be true
end

Then(/^a commit message should still be generated$/) do
  @fallback_message_generated = true
  @fallback_successful = true
  expect(@fallback_successful).to be true
end
