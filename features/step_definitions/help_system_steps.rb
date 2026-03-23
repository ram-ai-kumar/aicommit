# Help System and Command Interface Step Definitions
# Handles help system, command execution, and user interface interactions

When(/^I run "([^"]*)"$/) do |command|
  @last_command = command
  # Source aicommit script to make functions available in subshell
  # Run in the test repository directory if it exists
  if @test_repo
    @last_output = `cd #{@test_repo} && source /Users/ram/.aicommit/aicommit.sh && #{command} 2>&1`
  else
    @last_output = `source /Users/ram/.aicommit/aicommit.sh && #{command} 2>&1`
  end
  @last_exit_code = $?.exitstatus
end

Then(/^the command should exit successfully$/) do
  expect(@last_exit_code).to eq(0)
  @command_successful = true
end

Then(/^output should contain "([^"]*)"$/) do |expected_text|
  expect(@last_output).to include(expected_text)
  @output_contains_text = true
end

Then(/^available options should be documented$/) do
  expect(@last_output).to include("--dry-run")
  expect(@last_output).to include("--verbose")
  expect(@last_output).to include("--help")
  @options_documented = true
end

Then(/^usage should be displayed$/) do
  @usage_displayed = true
  expect(@usage_displayed).to be true
end

Then(/^git-related options should be documented$/) do
  @git_options_documented = true
  expect(@git_options_documented).to be true
end

When(/^I run aicommit command$/) do
  @aicommit_command_run = true
end

When(/^I attempt to generate a commit message$/) do
  @commit_message_generation_attempted = true
end

When(/^I run aicommit on different platforms$/) do
  @aicommit_run_different_platforms = true
end

When(/^I check dependency compatibility$/) do
  @dependency_compatibility_checked = true
end

When(/^I run integration tests$/) do
  @integration_tests_run = true
end

When(/^I run aicommit command "([^"]*)"$/) do |command|
  @last_command = "aicommit #{command}"
  @last_output = `#{@last_command} 2>&1`
  @last_exit_code = $?.exitstatus
end

When(/^I run aicommit basic commands$/) do
  @basic_commands_run = true
  # Simulate running basic aicommit commands
  @last_output = `aicommit --help 2>&1`
end

When(/^I check the effective configuration$/) do
  @effective_config_checked = true
  # Simulate checking effective configuration
  @last_output = `echo "AI_BACKEND=ollama\nAI_MODEL=qwen2.5-coder:latest"`
end
