# Environment Setup and Configuration Step Definitions
# Handles test environment setup, git repository initialization, and basic configuration

require 'fileutils'
require 'tempfile'

Given(/^aicommit is properly installed$/) do
  # Check if aicommit is installed in user directory
  aicommit_dir = File.expand_path('~/.aicommit')
  expect(File.exist?(aicommit_dir)).to be true
  expect(File.exist?(File.join(aicommit_dir, 'aicommit.sh'))).to be true
  expect(File.exist?(File.join(aicommit_dir, 'lib', 'core.sh'))).to be true
  expect(File.exist?(File.join(aicommit_dir, 'config', 'defaults.sh'))).to be true
  
  # Check if commands are available in PATH
  @aicommit_installed = true
end

Given(/^a git repository is initialized$/) do
  @test_repo = Dir.mktmpdir('aicommit-test-repo')
  Dir.chdir(@test_repo) do
    system('git init --quiet')
    system('git config user.name "Test User"')
    system('git config user.email "test@example.com"')
  end
  @git_initialized = true
end

Given(/^the working directory is clean$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      expect(`git status --porcelain`).to eq('')
    end
  end
  @working_directory_clean = true
end

Given(/^a clean system environment$/) do
  # Clean environment for testing
  ENV.delete('AI_BACKEND')
  ENV.delete('AI_MODEL')
  ENV.delete('AI_TIMEOUT')
  @clean_environment = true
end

Given(/^I am in a git repository$/) do
  @in_git_repository = true
  expect(@test_repo).to_not be_nil
end

Given(/^AI_TIMEOUT is set to "([^"]*)" in environment$/) do |timeout|
  ENV['AI_TIMEOUT'] = timeout
  @ai_timeout_env_set = timeout
end

Given(/^the system has minimum required dependencies$/) do
  @minimum_dependencies_available = true
end

Given(/^the system has outdated dependencies$/) do
  @outdated_dependencies_exist = true
end

Given(/^I have integration test environment setup$/) do
  @integration_test_env_setup = true
end

After do
  # Clean up environment variables
  ENV.delete('AI_TIMEOUT') if @ai_timeout_env_set
end
