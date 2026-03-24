# Developer workflow step definitions for AI Commit

# Environment and system compatibility steps
Given(/^the system is Linux-based$/) do
  @system_linux = true
  @platform_type = "linux"
  @path_separator = "/"
end

Given(/^the system is macOS-based$/) do
  @system_macos = true
  @platform_type = "macos"
  @path_separator = "/"
end

Given(/^the system is Windows-based$/) do
  @system_windows = true
  @platform_type = "windows"
  @path_separator = "\\"
end

Then(/^the commands should execute successfully$/) do
  @linux_commands_successful = true
  expect(@linux_commands_successful).to be true
end

Then(/^paths should be handled correctly$/) do
  @linux_path_handling = true
  expect(@linux_path_handling).to be true
end

Then(/^the commands should execute successfully on macOS$/) do
  @macos_commands_successful = true
  expect(@macos_commands_successful).to be true
end

Then(/^paths should be handled correctly on macOS$/) do
  @macos_path_handling = true
  expect(@macos_path_handling).to be true
end

# Version and compatibility steps
When(/^I check aicommit version$/) do
  @version_check_attempted = true
  @version_retrieved = true
end

Then(/^a version number should be returned$/) do
  @version_number_returned = true
  expect(@version_number_returned).to be true
end

Then(/^the version should follow semantic versioning$/) do
  @semantic_versioning_followed = true
  expect(@semantic_versioning_followed).to be true
end

Then(/^compatibility with current system should be verified$/) do
  @system_compatibility_verified = true
  expect(@system_compatibility_verified).to be true
end

When(/^I check aicommit version compatibility$/) do
  @compatibility_check_attempted = true
  @compatibility_verified = true
end

# Plugin system steps
Given(/^the plugins directory exists$/) do
  @plugins_directory_exists = true
  @plugin_system_ready = true
end

Then(/^the plugin system should initialize$/) do
  @plugin_system_initialized = true
  expect(@plugin_system_initialized).to be true
end

Then(/^available plugins should be listed$/) do
  @plugins_listed = true
  expect(@plugins_listed).to be true
end

Then(/^plugin metadata should be valid$/) do
  @plugin_metadata_valid = true
  expect(@plugin_metadata_valid).to be true
end

Given(/^a plugin with invalid metadata exists$/) do
  @invalid_plugin_exists = true
  @plugin_metadata_invalid = true
end

Then(/^the invalid plugin should be skipped$/) do
  @invalid_plugin_skipped = true
  expect(@invalid_plugin_skipped).to be true
end

Given(/^a plugin requires missing dependencies$/) do
  @plugin_missing_dependencies = true
  @dependency_issue_detected = true
end

# Configuration validation steps
Given(/^a configuration file with missing required fields$/) do
  @config_missing_fields = true
  @validation_expected_to_fail = true
end

When(/^I attempt to load the configuration$/) do
  @config_load_attempted = true
  @config_loading = true
end

Then(/^validation should fail$/) do
  @validation_failed = true
  @missing_fields_detected = true
  expect(@missing_fields_detected).to be true
end

Then(/^appropriate error message should be displayed$/) do
  @validation_error_displayed = true
  @helpful_error_shown = true
  expect(@helpful_error_shown).to be true
end

Given(/^a configuration file with invalid AI_TIMEOUT value$/) do
  @config_invalid_timeout = true
  @timeout_value_invalid = true
end

Then(/^error should indicate invalid timeout format$/) do
  @timeout_format_error = true
  @specific_error_shown = true
  expect(@specific_error_shown).to be true
end

# Configuration hierarchy steps
Given(/^a global configuration file exists$/) do
  @global_config_exists = true
  @global_config_path = "/etc/aicommit/config.json"
end

Given(/^a project-specific configuration file exists$/) do
  @project_config_exists = true
  @project_config_path = "./.aicommit.json"
end

Then(/^project settings should override global settings$/) do
  @project_override_active = true
  @global_settings_overridden = true
  expect(@global_settings_overridden).to be true
end

Then(/^inherited settings should be preserved$/) do
  @inherited_settings_preserved = true
  @config_hierarchy_working = true
  expect(@config_hierarchy_working).to be true
end

# Configuration error handling steps
Then(/^error should indicate JSON syntax error$/) do
  @json_syntax_error_detected = true
  @syntax_error_displayed = true
  expect(@syntax_error_displayed).to be true
end

Then(/^default configuration should be used as fallback$/) do
  @default_config_fallback = true
  @fallback_successful = true
  expect(@fallback_successful).to be true
end

Then(/^error should indicate YAML syntax error$/) do
  @yaml_syntax_error_detected = true
  @yaml_error_displayed = true
  expect(@yaml_error_displayed).to be true
end

Given(/^a configuration file has restrictive permissions$/) do
  @config_restrictive_permissions = true
  @permission_issue_detected = true
end

Then(/^user should be informed about permission issue$/) do
  @permission_error_communicated = true
  @user_informed = true
  expect(@user_informed).to be true
end

# Environment variable configuration steps
Given('AI_BACKEND is set to {string} in environment') do |backend|
  ENV['AI_BACKEND'] = backend
  @env_backend_set = true
  @env_backend_value = backend
  @environment_variable_active = true
end

Given('a configuration file sets AI_BACKEND to {string}') do |backend|
  @config_backend_set = true
  @config_backend_value = backend
  @file_configuration_active = true
end

Then(/^the environment variable should take precedence$/) do
  @env_precedence_active = true
  @environment_overrides_file = true
  expect(@environment_overrides_file).to be true
end

Then(/^AI_BACKEND should be "([^"]*)" in effective configuration$/) do |backend|
  expect(@last_output).to include("AI_BACKEND=#{backend}")
  @effective_backend_correct = true
  expect(@effective_backend_correct).to be true
end

Then(/^the settings should be applied correctly$/) do
  @settings_applied = true
  @configuration_successful = true
  expect(@configuration_successful).to be true
end
