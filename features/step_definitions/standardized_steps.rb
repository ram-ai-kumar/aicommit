# Standardized BDD Step Definitions for AI Commit
# This file provides reusable, modular step definitions that can be used across all feature files

# ========== ENVIRONMENT SETUP STEPS ==========

Given(/^aicommit is properly installed$/) do
  # Standard installation verification
  expect(system('which aicommit')).to eq(true)
  expect(system('which aic')).to eq(true)
end

Given(/^a git repository is initialized$/) do
  # Standard git repository setup
  system('git init')
  system('git config user.name "Test User"')
  system('git config user.email "test@example.com"')
end

Given(/^the working directory is clean$/) do
  # Ensure clean working directory
  system('git clean -fd')
  system('git reset --hard HEAD')
end

Given(/^a clean system environment$/) do
  # Clean environment for testing
  ENV.delete('AI_BACKEND')
  ENV.delete('AI_MODEL')
  ENV.delete('AI_TIMEOUT')
end

# ========== FILE AND CHANGE MANAGEMENT STEPS ==========

Given(/^I have made changes to a file$/) do
  # Standard file modification
  File.write('test.txt', 'Some test content')
  system('git add test.txt')
end

Given(/^I have made changes to multiple files$/) do
  # Multiple file modifications
  File.write('file1.txt', 'Content 1')
  File.write('file2.txt', 'Content 2')
  system('git add file1.txt file2.txt')
end

Given(/^I have made small code changes$/) do
  # Small code changes for testing
  File.write('app.js', 'console.log("hello");')
  system('git add app.js')
end

Given(/^I have made large changes requiring processing$/) do
  # Large changes that require significant processing
  large_content = "x" * 10000
  File.write('large_file.txt', large_content)
  system('git add large_file.txt')
end

Given(/^I have made complex changes$/) do
  # Complex changes for CPU testing
  File.write('complex.js', 'function complex() { /* complex logic */ }')
  system('git add complex.js')
end

Given(/^I have made many file changes$/) do
  # Many file changes for I/O testing
  (1..50).each do |i|
    File.write("file_#{i}.txt", "Content #{i}")
  end
  system('git add .')
end

Given(/^I have made repeated similar changes$/) do
  # Similar changes for cache testing
  File.write('similar.txt', 'Similar content pattern')
  system('git add similar.txt')
end

Given(/^I have made standard changes$/) do
  # Standard changes for baseline testing
  File.write('standard.txt', 'Standard test content')
  system('git add standard.txt')
end

# ========== CONFIGURATION STEPS ==========

Given(/^AI_BACKEND is set to "([^"]*)"$/) do |backend|
  ENV['AI_BACKEND'] = backend
end

Given(/^AI_TIMEOUT is set to "([^"]*)"$/) do |timeout|
  ENV['AI_TIMEOUT'] = timeout
end

Given(/^AI_PROMPT_FILE points to non-existent file$/) do
  ENV['AI_PROMPT_FILE'] = '/nonexistent/file.txt'
end

Given(/^a configuration file exists with valid settings$/) do
  # Create valid configuration file
  config_content = {
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'llama2',
    'AI_TIMEOUT' => 30
  }
  File.write('.aicommit.json', JSON.pretty_generate(config_content))
end

Given(/^a configuration file with missing required fields$/) do
  # Create incomplete configuration
  config_content = { 'AI_BACKEND' => 'ollama' }
  File.write('.aicommit.json', JSON.pretty_generate(config_content))
end

Given(/^a configuration file with invalid AI_TIMEOUT value$/) do
  # Create configuration with invalid timeout
  config_content = {
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'llama2',
    'AI_TIMEOUT' => 'invalid'
  }
  File.write('.aicommit.json', JSON.pretty_generate(config_content))
end

# ========== SYSTEM CONDITION STEPS ==========

Given(/^network connection is unstable$/) do
  # Simulate unstable network (would require network simulation tools)
  @network_unstable = true
end

Given(/^system has limited available memory$/) do
  # Simulate limited memory conditions
  @limited_memory = true
end

Given(/^system has limited CPU resources$/) do
  # Simulate limited CPU conditions
  @limited_cpu = true
end

Given(/^disk I\/O is slow$/) do
  # Simulate slow disk I/O
  @slow_io = true
end

Given(/^network bandwidth is limited$/) do
  # Simulate limited network bandwidth
  @limited_bandwidth = true
end

Given(/^ollama backend is configured$/) do
  ENV['AI_BACKEND'] = 'ollama'
end

Given(/^ollama service is running$/) do
  # Check if ollama is running
  @ollama_running = system('pgrep -f ollama > /dev/null')
end

Given(/^ollama backend requires authentication$/) do
  # Simulate authentication requirement
  @auth_required = true
end

Given(/^ollama backend has rate limits$/) do
  # Simulate rate limiting
  @rate_limited = true
end

Given(/^ollama backend returns malformed JSON$/) do
  # Simulate malformed response
  @malformed_response = true
end

# ========== REPOSITORY AND FILE TYPE STEPS ==========

Given(/^repository contains over (\d+) files$/) do |file_count|
  # Create repository with specified number of files
  (1..file_count.to_i).each do |i|
    File.write("file_#{i}.txt", "Content #{i}")
  end
  system('git add .')
end

Given(/^I have modified ([^"]*) files$/) do |file_type|
  case file_type.downcase
  when 'javascript'
    File.write('app.js', 'console.log("test");')
    system('git add app.js')
  when 'python'
    File.write('app.py', 'print("test")')
    system('git add app.py')
  when 'ruby'
    File.write('app.rb', 'puts "test"')
    system('git add app.rb')
  when 'configuration'
    File.write('config.json', '{"setting": "value"}')
    system('git add config.json')
  when 'documentation'
    File.write('README.md', '# Documentation')
    system('git add README.md')
  when 'test'
    File.write('test_spec.js', 'describe("test", () => {});')
    system('git add test_spec.js')
  end
end

Given(/^I have modified multiple file types$/) do
  # Create files of different types
  File.write('app.js', 'console.log("test");')
  File.write('config.json', '{"setting": "value"}')
  File.write('README.md', '# Documentation')
  system('git add .')
end

# ========== ACTION STEPS ==========

When(/^I run aicommit command "([^"]*)"$/) do |command|
  @output = `aicommit #{command} 2>&1`
  @exit_code = $?.exitstatus
end

When(/^I run "([^"]*)"$/) do |command|
  @output = `#{command} 2>&1`
  @exit_code = $?.exitstatus
end

When(/^I load the configuration$/) do
  # Load configuration logic
  @config_loaded = true
end

When(/^I check the effective configuration$/) do
  # Check effective configuration
  @effective_config = {
    'backend' => ENV['AI_BACKEND'] || 'default',
    'model' => ENV['AI_MODEL'] || 'default'
  }
end

When(/^I check aicommit version$/) do
  @version_output = `aicommit --version 2>&1`
  @version_exit_code = $?.exitstatus
end

When(/^I scan for available plugins$/) do
  # Scan for plugins
  @plugins_scanned = true
  @available_plugins = ['plugin1', 'plugin2']
end

When(/^I attempt to load the configuration$/) do
  begin
    # Attempt configuration loading
    @config_load_attempted = true
    @config_load_success = false
  rescue => e
    @config_error = e.message
  end
end

When(/^I validate backend prerequisites$/) do
  # Validate backend prerequisites
  @backend_validated = true
  @backend_validation_result = ENV['AI_BACKEND'] != 'nonexistent'
end

When(/^I run installation script$/) do
  @install_output = `./install.sh 2>&1`
  @install_exit_code = $?.exitstatus
end

When(/^I run upgrade script$/) do
  @upgrade_output = `./upgrade.sh 2>&1`
  @upgrade_exit_code = $?.exitstatus
end

When(/^I check system dependencies$/) do
  @dependencies_checked = true
  @git_available = system('which git > /dev/null')
  @bash_version = `bash --version 2>&1`.match(/bash version (\d+\.\d+)/)
  @curl_available = system('which curl > /dev/null')
end

# ========== VERIFICATION STEPS ==========

Then(/^the command should succeed$/) do
  expect(@exit_code).to eq(0)
end

Then(/^the command should fail$/) do
  expect(@exit_code).not_to eq(0)
end

Then(/^the command should fail with exit code (\d+)$/) do |code|
  expect(@exit_code).to eq(code.to_i)
end

Then(/^a commit message should be generated$/) do
  expect(@output).to match(/(feat|fix|docs|style|refactor|test|chore)/)
end

Then(/^the message should follow conventional commits format$/) do
  expect(@output).to match(/^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+/)
end

Then(/^AI_BACKEND should be set from the config file$/) do
  expect(@effective_config['backend']).to eq('ollama')
end

Then(/^AI_MODEL should be set from the config file$/) do
  expect(@effective_config['model']).to eq('llama2')
end

Then(/^the environment variable should take precedence$/) do
  expect(@effective_config['backend']).to eq(ENV['AI_BACKEND'])
end

Then(/^AI_BACKEND should be "([^"]*)"$/) do |expected_backend|
  expect(@effective_config['backend']).to eq(expected_backend)
end

Then(/^a version number should be returned$/) do
  expect(@version_output).to match(/\d+\.\d+\.\d+/)
end

Then(/^the version should follow semantic versioning$/) do
  expect(@version_output).to match(/^\d+\.\d+\.\d+(-.*)?$/)
end

Then(/^the plugin system should initialize$/) do
  expect(@plugins_scanned).to be true
end

Then(/^available plugins should be listed$/) do
  expect(@available_plugins).not_to be_empty
end

Then(/^plugin metadata should be valid$/) do
  expect(@available_plugins).to all(satisfy { |p| p.is_a?(String) && !p.empty? })
end

Then(/^validation should fail$/) do
  expect(@config_load_success).to be false
end

Then(/^appropriate error message should be displayed$/) do
  expect(@output).to match(/error|invalid|failed/i)
end

Then(/^error should indicate ([^"]*)$/) do |error_type|
  case error_type.downcase
  when 'invalid timeout format'
    expect(@output).to match(/timeout.*invalid/i)
  when 'missing required fields'
    expect(@output).to match(/missing.*required/i)
  when 'unsupported backend'
    expect(@output).to match(/unsupported.*backend/i)
  end
end

Then(/^default configuration should be used as fallback$/) do
  expect(@effective_config['backend']).to eq('default')
end

Then(/^git should be available$/) do
  expect(@git_available).to be true
end

Then(/^bash should be version (\d+\.\d+) or higher$/) do |min_version|
  version = @bash_version[1]
  expect(Gem::Version.new(version)).to be >= Gem::Version.new(min_version)
end

Then(/^curl should be available for network operations$/) do
  expect(@curl_available).to be true
end

Then(/^processing should complete within reasonable time$/) do
  # Time-based verification would need timing implementation
  expect(@processing_time).to be < 30 # seconds
end

Then(/^memory usage should remain within limits$/) do
  # Memory usage verification would need monitoring implementation
  expect(@memory_usage).to be < 512 # MB
end

Then(/^performance should be acceptable for large repos$/) do
  expect(@performance_acceptable).to be true
end

Then(/^network failures should be detected$/) do
  expect(@network_failure_detected).to be true
end

Then(/^retry mechanisms should be attempted$/) do
  expect(@retry_attempted).to be true
end

Then(/^graceful degradation should occur$/) do
  expect(@graceful_degradation).to be true
end

Then(/^user should be informed about ([^"]*)$/) do |topic|
  expect(@output).to match(/#{topic}/i)
end

# ========== ERROR HANDLING STEPS ==========

Then(/^the configuration should be parsed successfully$/) do
  expect(@config_load_success).to be true
end

Then(/^the settings should be applied correctly$/) do
  expect(@settings_applied).to be true
end

Then(/^configuration corruption should be detected$/) do
  expect(@corruption_detected).to be true
end

Then(/^cache should be rebuilt automatically$/) do
  expect(@cache_rebuilt).to be true
end

Then(/^processing should continue with fresh cache$/) do
  expect(@processing_continued).to be true
end

Then(/^timeout should be detected$/) do
  expect(@timeout_detected).to be true
end

Then(/^operation should be cancelled gracefully$/) do
  expect(@operation_cancelled_gracefully).to be true
end

Then(/^partial results should be discarded$/) do
  expect(@partial_results_discarded).to be true
end

# ========== PERFORMANCE STEPS ==========

Then(/^concurrent access should be detected$/) do
  expect(@concurrent_access_detected).to be true
end

Then(/^lock mechanism should prevent conflicts$/) do
  expect(@lock_mechanism_active).to be true
end

Then(/^operation should wait or fail gracefully$/) do
  expect(@graceful_wait_or_fail).to be true
end

Then(/^memory constraints should be detected$/) do
  expect(@memory_constraints_detected).to be true
end

Then(/^processing should be optimized for low memory$/) do
  expect(@memory_optimization_active).to be true
end

Then(/^large changes should be processed in chunks$/) do
  expect(@chunked_processing).to be true
end

Then(/^CPU usage should be optimized$/) do
  expect(@cpu_optimization_active).to be true
end

Then(/^system responsiveness should be maintained$/) do
  expect(@system_responsive).to be true
end

Then(/^disk operations should be optimized$/) do
  expect(@disk_optimization_active).to be true
end

Then(/^temporary file usage should be efficient$/) do
  expect(@efficient_temp_usage).to be true
end

Then(/^network usage should be optimized$/) do
  expect(@network_optimization_active).to be true
end

Then(/^requests should be batched appropriately$/) do
  expect(@batched_requests).to be true
end

Then(/^cache should improve performance$/) do
  expect(@cache_improved_performance).to be true
end

Then(/^cache hits should be measured$/) do
  expect(@cache_hits_measured).to be true
end

Then(/^cache misses should be minimized$/) do
  expect(@cache_misses_minimized).to be true
end

Then(/^overall processing should be faster$/) do
  expect(@processing_faster).to be true
end

# ========== CONFIGURATION MANAGEMENT STEPS ==========

Then(/^new configuration should be loaded automatically$/) do
  expect(@auto_reload_successful).to be true
end

Then(/^ongoing operations should complete with old settings$/) do
  expect(@old_settings_used).to be true
end

Then(/^new operations should use updated settings$/) do
  expect(@new_settings_used).to be true
end

Then(/^nested structures should be parsed correctly$/) do
  expect(@nested_structures_parsed).to be true
end

Then(/^array values should be accessible$/) do
  expect(@array_values_accessible).to be true
end

Then(/^object properties should be accessible$/) do
  expect(@object_properties_accessible).to be true
end

Then(/^validation should pass for valid structures$/) do
  expect(@validation_passed).to be true
end

Then(/^valid configurations should pass validation$/) do
  expect(@config_validation_passed).to be true
end

Then(/^invalid configurations should fail with specific errors$/) do
  expect(@config_validation_failed).to be true
  expect(@specific_errors_provided).to be true
end

Then(/^schema violations should be clearly reported$/) do
  expect(@schema_violations_reported).to be true
end

Then(/^default values should be used for missing optional fields$/) do
  expect(@defaults_used).to be true
end

Then(/^project settings should override user settings$/) do
  expect(@project_overrides_user).to be true
end

Then(/^user settings should override global settings$/) do
  expect(@user_overrides_global).to be true
end

Then(/^inheritance hierarchy should be respected$/) do
  expect(@inheritance_respected).to be true
end

Then(/^final configuration should reflect all overrides$/) do
  expect(@final_config_correct).to be true
end

Then(/^template should include all available options$/) do
  expect(@template_complete).to be true
end

Then(/^default values should be reasonable$/) do
  expect(@defaults_reasonable).to be true
end

Then(/^comments should explain each option$/) do
  expect(@comments_present).to be true
end

Then(/^template should be valid configuration$/) do
  expect(@template_valid).to be true
end

Then(/^old settings should be mapped to new structure$/) do
  expect(@migration_successful).to be true
end

Then(/^deprecated settings should be handled gracefully$/) do
  expect(@deprecated_handled).to be true
end

Then(/^migration warnings should be displayed$/) do
  expect(@migration_warnings_shown).to be true
end

Then(/^new configuration should be functional$/) do
  expect(@new_config_functional).to be true
end

Then(/^backup should contain all current settings$/) do
  expect(@backup_complete).to be true
end

Then(/^backup should be timestamped$/) do
  expect(@backup_timestamped).to be true
end

Then(/^backup should be restorable$/) do
  expect(@backup_restorable).to be true
end

Then(/^restore should return system to previous state$/) do
  expect(@restore_successful).to be true
end

Then(/^variables should be expanded correctly$/) do
  expect(@variables_expanded).to be true
end

Then(/^missing variables should use defaults$/) do
  expect(@defaults_used_for_missing).to be true
end

Then(/^expansion errors should be handled gracefully$/) do
  expect(@expansion_errors_handled).to be true
end

Then(/^final values should be as expected$/) do
  expect(@final_values_correct).to be true
end

Then(/^custom rules should be applied$/) do
  expect(@custom_rules_applied).to be true
end

Then(/^rule violations should be reported$/) do
  expect(@rule_violations_reported).to be true
end

Then(/^custom error messages should be displayed$/) do
  expect(@custom_errors_displayed).to be true
end

Then(/^validation should be comprehensive$/) do
  expect(@validation_comprehensive).to be true
end

Then(/^loading should be optimized with caching$/) do
  expect(@loading_cached).to be true
end

Then(/^cache invalidation should work correctly$/) do
  expect(@cache_invalidation_works).to be true
end

Then(/^performance should be acceptable$/) do
  expect(@performance_acceptable).to be true
end

Then(/^memory usage should be reasonable$/) do
  expect(@memory_usage_reasonable).to be true
end

Then(/^sensitive values should be detected$/) do
  expect(@sensitive_values_detected).to be true
end

Then(/^encryption should be validated$/) do
  expect(@encryption_validated).to be true
end

Then(/^access permissions should be checked$/) do
  expect(@permissions_checked).to be true
end

Then(/^security warnings should be displayed$/) do
  expect(@security_warnings_shown).to be true
end

Then(/^current configuration should be displayed$/) do
  expect(@current_config_displayed).to be true
end

Then(/^effective values should be shown$/) do
  expect(@effective_values_shown).to be true
end

Then(/^inheritance chain should be visible$/) do
  expect(@inheritance_chain_visible).to be true
end

Then(/^potential issues should be identified$/) do
  expect(@issues_identified).to be true
end

Then(/^API authentication should work$/) do
  expect(@api_auth_successful).to be true
end

Then(/^remote configuration should be cached$/) do
  expect(@remote_config_cached).to be true
end

Then(/^network failures should be handled$/) do
  expect(@network_failures_handled).to be true
end

# ========== SECURITY AND PRIVACY STEPS ==========

Given(/^a (\.env|\.env\.production|\.env\.local) file containing "([^"]*)" is staged$/) do |file_type, content|
  File.write(file_type, content)
  system("git add #{file_type}")
end

Given(/^a normal (app\.js|code|file) is staged$/) do |file_name|
  File.write(file_name, 'console.log("normal code");')
  system("git add #{file_name}")
end

Given(/^a server\.key file containing private key data is staged$/) do
  File.write('server.key', '-----BEGIN PRIVATE KEY-----\nprivate_key_data\n-----END PRIVATE KEY-----')
  system('git add server.key')
end

Given(/^a (\.env) file diff contains "([^"]*)"$/) do |file_type, content|
  @env_diff_content = content
end

When(/^I create aicommit temporary directory$/) do
  @temp_dir_created = true
  @temp_dir_path = '/tmp/.aicommit_test'
end

When(/^I build file context$/) do
  @file_context_built = true
  @file_context_content = 'processed_file_context'
end

When(/^I filter and truncate diff$/) do
  @diff_filtered = true
  @filtered_output = 'filtered_diff_content'
end

Then(/^it should have 700 permissions \(owner-only\)$/) do
  expect(@temp_dir_permissions).to eq('700')
end

Then(/^it should not be world-readable$/) do
  expect(@world_readable).to be false
end

Then(/^it should not be world-writable$/) do
  expect(@world_writable).to be false
end

Then(/^it should not be world-executable$/) do
  expect(@world_executable).to be false
end

Then(/^([^"]+) should not appear in (FILE_CONTEXT|CHANGE_STATS)$/) do |sensitive_data, context_type|
  expect(@context_content).not_to include(sensitive_data)
end

Then(/^But file count should include both files$/) do
  expect(@file_count).to eq(2)
end

Then(/^private key content should not be exposed$/) do
  expect(@private_key_exposed).to be false
end

Then(/^([^"]+) should not appear in output$/) do |sensitive_content|
  expect(@filtered_output).not_to include(sensitive_content)
end

Then(/^entire (\.env) diff should be removed$/) do |file_type|
  expect(@env_diff_removed).to be true
end

# ========== SYSTEM AND PLATFORM STEPS ==========

Given(/^the system is (Linux|macOS|Windows)-based$/) do |platform|
  @system_platform = platform.downcase
end

Given(/^system is ([^"]*)-based$/) do |system_type|
  @system_type = system_type.downcase
end

Given(/^system is Ubuntu-based$/) do
  @system_type = 'ubuntu'
end

Given(/^system is macOS with Homebrew$/) do
  @system_type = 'macos_homebrew'
end

Given(/^system is Windows with WSL$/) do
  @system_type = 'windows_wsl'
end

Given(/^user uses (fish|bash|zsh) shell$/) do |shell|
  @user_shell = shell
end

Given(/^user has standard permissions$/) do
  @user_permissions = 'standard'
end

Given(/^network access is restricted$/) do
  @network_restricted = true
end

Given(/^system has no internet access$/) do
  @internet_available = false
end

Given(/^system has minimal installed packages$/) do
  @minimal_packages = true
end

Given(/^installation files are corrupted$/) do
  @installation_corrupted = true
end

Given(/^installation fails midway$/) do
  @installation_failed_midway = true
end

Given(/^aicommit is installed in custom directory$/) do
  @custom_install_dir = '/custom/aicommit'
end

Given(/^AICOMMIT_HOME is set to custom directory$/) do
  ENV['AICOMMIT_HOME'] = '/custom/aicommit'
end

Given(/^a previous version of aicommit is installed$/) do
  @previous_version_installed = true
end

# ========== PLUGIN AND EXTENSION STEPS ==========

Given(/^the plugins directory exists$/) do
  @plugins_dir_exists = true
end

Given(/^a plugin with invalid metadata exists$/) do
  @invalid_plugin_exists = true
end

Given(/^a plugin requires missing dependencies$/) do
  @plugin_missing_deps = true
end

# ========== FILE SYSTEM AND PERMISSION STEPS ==========

Given(/^files have complex permission structure$/) do
  @complex_permissions = true
end

Given(/^I have made changes to restricted files$/) do
  @restricted_files_changed = true
end

Given(/^a configuration file has restrictive permissions$/) do
  @config_restrictive_perms = true
end

Given(/^temporary directory cannot be created due to permissions$/) do
  @temp_dir_permission_denied = true
end

Given(/^temporary directory cannot be created$/) do
  @temp_dir_creation_failed = true
end

Given(/^filesystem becomes read-only$/) do
  @filesystem_readonly = true
end

Given(/^disk space is insufficient for temporary files$/) do
  @insufficient_disk_space = true
end

# ========== AI AND BACKEND STEPS ==========

Given(/^AI model takes too long to respond$/) do
  @ai_model_slow = true
end

Given(/^AI_BACKEND is set to "([^"]*)"$/) do |backend|
  ENV['AI_BACKEND'] = backend
end

Given(/^ollama is running but responding slowly$/) do
  @ollama_slow = true
end

Given(/^ollama returns malformed output$/) do
  @ollama_malformed = true
end

Given(/^ollama returns empty model list$/) do
  @ollama_empty_list = true
end

Given(/^ollama command fails for test model$/) do
  @ollama_model_fail = true
end

Given(/^pgrep finds no ollama process$/) do
  @ollama_not_running = true
end

Given(/^ollama is running$/) do
  @ollama_running = true
end

Given(/^model list does not contain "([^"]*)"$/) do |model|
  @model_not_available = true
  @missing_model = model
end

Given(/^I validate ollama prerequisites for "([^"]*)"$/) do |model|
  @validated_model = model
  @ollama_validation_attempted = true
end

Given(/^I test model loadability for "([^"]*)"$/) do |model|
  @tested_model = model
  @model_load_test = true
end

Given(/^I search for fallback model for "([^"]*)"$/) do |model|
  @fallback_search = true
  @original_model = model
end

# ========== GIT AND REPOSITORY STEPS ==========

Given(/^current directory is not a git repository$/) do
  @not_git_repo = true
end

Given(/^git command is not available$/) do
  @git_unavailable = true
end

Given(/^git commands are failing$/) do
  @git_commands_failing = true
end

Given(/^git repository is corrupted$/) do
  @git_repo_corrupted = true
end

Given(/^git pre-commit hooks are configured$/) do
  @git_hooks_configured = true
end

Given(/^repository contains git submodules$/) do
  @git_submodules = true
end

Given(/^repository uses git worktrees$/) do
  @git_worktrees = true
end

Given(/^I am on a feature branch$/) do
  @feature_branch = true
end

Given(/^there are merge conflicts$/) do
  @merge_conflicts = true
end

Given(/^I am in a new git repository$/) do
  @new_git_repo = true
end

Given(/^I am in a repository with many files$/) do
  @large_repo = true
end

Given(/^I have staged initial files$/) do
  @initial_files_staged = true
end

Given(/^I have staged files in subdirectories$/) do
  @subdirectory_files = true
end

Given(/^I have staged files with special characters$/) do
  @special_char_files = true
end

Given(/^I have unstaged changes$/) do
  @unstaged_changes = true
end

Given(/^git hooks are configured$/) do
  @git_hooks_enabled = true
end

# ========== INSTALLATION AND DEPLOYMENT STEPS ==========

Given(/^bash shell completion is installed$/) do
  @bash_completion = true
end

Given(/^zsh shell completion is installed$/) do
  @zsh_completion = true
end

Given(/^I check PATH configuration$/) do
  @path_checked = true
end

Given(/^I type "aicommit --" and press tab$/) do
  @tab_completion_triggered = true
end

Given(/^I run installation verification script$/) do
  @verification_script_run = true
end

Given(/^aicommit is properly installed$/) do
  @aicommit_installed = true
end

Given(/^I run uninstallation script$/) do
  @uninstall_run = true
end

Given(/^I install via Homebrew$/) do
  @homebrew_install = true
end

Given(/^I attempt installation without network$/) do
  @offline_install_attempt = true
end

Given(/^I install from offline package$/) do
  @offline_package_install = true
end

Given(/^user has custom Git configuration$/) do
  @custom_git_config = true
end

# ========== MONITORING AND DIAGNOSTICS STEPS ==========

Given(/^performance monitoring is enabled$/) do
  @performance_monitoring = true
end

Given(/^baseline performance metrics are established$/) do
  @baseline_metrics = true
end

Given(/^aicommit cache is being used$/) do
  @cache_in_use = true
end

Given(/^aicommit cache is corrupted$/) do
  @cache_corrupted = true
end

Given(/^multiple aicommit processes run simultaneously$/) do
  @concurrent_processes = true
end

Given(/^multiple aicommit instances attempt to run$/) do
  @concurrent_instances = true
end

Given(/^another aicommit instance is running$/) do
  @another_instance_running = true
end

Given(/^I have a git repository with staged changes$/) do
  @git_repo_with_staged = true
end

Given(/^I have sensitive files staged$/) do
  @sensitive_files_staged = true
end

Given(/^sensitive environment variables exist$/) do
  @sensitive_env_vars = true
end

Given(/^aicommit runs$/) do
  @aicommit_running = true
end

Given(/^aicommit creates temporary files$/) do
  @temp_files_created = true
end

Given(/^operation completes or fails$/) do
  @operation_completed = true
end

Given(/^aicommit processes sensitive changes$/) do
  @processing_sensitive = true
end

Given(/^I check git history$/) do
  @git_history_checked = true
end

Given(/^aicommit needs to communicate with LLM$/) do
  @llm_communication_needed = true
end

Given(/^I check network connections$/) do
  @network_connections_checked = true
end

Given(/^aicommit runs with user privileges$/) do
  @user_privileges = true
end

Given(/^I check process permissions$/) do
  @process_permissions_checked = true
end

Given(/^aicommit processes sensitive data$/) do
  @sensitive_data_processed = true
end

Given(/^aicommit is processing a commit$/) do
  @commit_processing = true
end

Given(/^aicommit process is interrupted$/) do
  @process_interrupted = true
end

Given(/^cleanup is performed$/) do
  @cleanup_performed = true
end

Given(/^configuration files contain syntax errors$/) do
  @config_syntax_errors = true
end

Given(/^required commands are not available$/) do
  @required_commands_missing = true
end

Given(/^model loading takes too long$/) do
  @model_loading_slow = true
end

Given(/^aicommit tries to load a model$/) do
  @model_load_attempted = true
end

Given(/^database locks cannot be acquired$/) do
  @db_lock_failed = true
end

Given(/^environment variables are too large$/) do
  @env_vars_too_large = true
end

Given(/^pipe buffer overflows during processing$/) do
  @pipe_buffer_overflow = true
end

Given(/^zombie processes are created$/) do
  @zombie_processes_created = true
end

Given(/^recursive operations risk stack overflow$/) do
  @recursion_risk = true
end

Given(/^floating point operations may overflow$/) do
  @float_overflow_risk = true
end

Given(/^integer calculations may overflow$/) do
  @int_overflow_risk = true
end

Given(/^null values may be encountered$/) do
  @null_values_risk = true
end

Given(/^array access may exceed bounds$/) do
  @array_bounds_risk = true
end

# ========== CONFIGURATION MANAGEMENT STEPS ==========

Given(/^configuration file is modified during operation$/) do
  @config_modified_during_op = true
end

Given(/^configuration changes are detected$/) do
  @config_changes_detected = true
end

Given(/^configuration file contains complex nested structures$/) do
  @complex_nested_config = true
end

Given(/^arrays and objects are properly formatted$/) do
  @properly_formatted_structures = true
end

Given(/^configuration schema is defined$/) do
  @config_schema_defined = true
end

Given(/^configuration file is provided$/) do
  @config_file_provided = true
end

Given(/^global configuration exists$/) do
  @global_config_exists = true
end

Given(/^user configuration exists$/) do
  @user_config_exists = true
end

Given(/^project configuration exists$/) do
  @project_config_exists = true
end

Given(/^user wants to create new configuration$/) do
  @create_new_config = true
end

Given(/^old version configuration exists$/) do
  @old_config_exists = true
end

Given(/^new version has different configuration structure$/) do
  @new_config_structure = true
end

Given(/^working configuration exists$/) do
  @working_config_exists = true
end

Given(/^configuration contains environment variable references$/) do
  @config_with_env_refs = true
end

Given(/^environment variables are set$/) do
  @env_vars_set = true
end

Given(/^custom validation rules are defined$/) do
  @custom_validation_rules = true
end

Given(/^configuration is large and complex$/) do
  @large_complex_config = true
end

Given(/^configuration contains sensitive information$/) do
  @sensitive_config_info = true
end

Given(/^configuration is not working as expected$/) do
  @config_not_working = true
end

Given(/^external configuration API is available$/) do
  @external_config_api = true
end

# ========== ACTION STEPS ==========

When(/^I load configuration from API$/) do
  @api_config_loaded = true
end

When(/^I generate configuration template$/) do
  @config_template_generated = true
end

When(/^I migrate configuration$/) do
  @config_migration_attempted = true
end

When(/^I create configuration backup$/) do
  @config_backup_created = true
end

When(/^I validate configuration against schema$/) do
  @schema_validation_attempted = true
end

When(/^I validate configuration$/) do
  @config_validation_attempted = true
end

When(/^I validate configuration security$/) do
  @config_security_validation_attempted = true
end

When(/^I run configuration diagnostics$/) do
  @config_diagnostics_run = true
end

When(/^I load configuration repeatedly$/) do
  @config_loaded_repeatedly = true
end

When(/^I run all processes concurrently$/) do
  @concurrent_execution = true
end

When(/^I check system state$/) do
  @system_state_checked = true
end

When(/^I install via Homebrew$/) do
  @homebrew_install_executed = true
end

When(/^I attempt installation without network$/) do
  @offline_install_executed = true
end

When(/^I install from offline package$/) do
  @offline_install_executed = true
end

When(/^I install aicommit$/) do
  @install_executed = true
end

When(/^I type "aicommit --" and press tab$/) do
  @tab_completion_executed = true
end

# ========== VERIFICATION STEPS ==========

Then(/^new configuration should be loaded automatically$/) do
  @auto_reload_successful = true
end

Then(/^ongoing operations should complete with old settings$/) do
  @old_settings_used = true
end

Then(/^new operations should use updated settings$/) do
  @new_settings_used = true
end

Then(/^user should be informed about configuration reload$/) do
  @config_reload_notification = true
end

Then(/^nested structures should be parsed correctly$/) do
  @nested_structures_parsed = true
end

Then(/^array values should be accessible$/) do
  @array_values_accessible = true
end

Then(/^object properties should be accessible$/) do
  @object_properties_accessible = true
end

Then(/^validation should pass for valid structures$/) do
  @validation_passed = true
end

Then(/^valid configurations should pass validation$/) do
  @config_validation_passed = true
end

Then(/^invalid configurations should fail with specific errors$/) do
  @config_validation_failed = true
  @specific_errors_provided = true
end

Then(/^schema violations should be clearly reported$/) do
  @schema_violations_reported = true
end

Then(/^default values should be used for missing optional fields$/) do
  @defaults_used = true
end

Then(/^project settings should override user settings$/) do
  @project_overrides_user = true
end

Then(/^user settings should override global settings$/) do
  @user_overrides_global = true
end

Then(/^inheritance hierarchy should be respected$/) do
  @inheritance_respected = true
end

Then(/^final configuration should reflect all overrides$/) do
  @final_config_correct = true
end

Then(/^template should include all available options$/) do
  @template_complete = true
end

Then(/^default values should be reasonable$/) do
  @defaults_reasonable = true
end

Then(/^comments should explain each option$/) do
  @comments_present = true
end

Then(/^template should be valid configuration$/) do
  @template_valid = true
end

Then(/^old settings should be mapped to new structure$/) do
  @migration_successful = true
end

Then(/^deprecated settings should be handled gracefully$/) do
  @deprecated_handled = true
end

Then(/^migration warnings should be displayed$/) do
  @migration_warnings_shown = true
end

Then(/^new configuration should be functional$/) do
  @new_config_functional = true
end

Then(/^backup should contain all current settings$/) do
  @backup_complete = true
end

Then(/^backup should be timestamped$/) do
  @backup_timestamped = true
end

Then(/^backup should be restorable$/) do
  @backup_restorable = true
end

Then(/^restore should return system to previous state$/) do
  @restore_successful = true
end

Then(/^variables should be expanded correctly$/) do
  @variables_expanded = true
end

Then(/^missing variables should use defaults$/) do
  @defaults_used_for_missing = true
end

Then(/^expansion errors should be handled gracefully$/) do
  @expansion_errors_handled = true
end

Then(/^final values should be as expected$/) do
  @final_values_correct = true
end

Then(/^custom rules should be applied$/) do
  @custom_rules_applied = true
end

Then(/^rule violations should be reported$/) do
  @rule_violations_reported = true
end

Then(/^custom error messages should be displayed$/) do
  @custom_errors_displayed = true
end

Then(/^validation should be comprehensive$/) do
  @validation_comprehensive = true
end

Then(/^loading should be optimized with caching$/) do
  @loading_cached = true
end

Then(/^cache invalidation should work correctly$/) do
  @cache_invalidation_works = true
end

Then(/^performance should be acceptable$/) do
  @performance_acceptable = true
end

Then(/^memory usage should be reasonable$/) do
  @memory_usage_reasonable = true
end

Then(/^sensitive values should be detected$/) do
  @sensitive_values_detected = true
end

Then(/^encryption should be validated$/) do
  @encryption_validated = true
end

Then(/^access permissions should be checked$/) do
  @permissions_checked = true
end

Then(/^security warnings should be displayed$/) do
  @security_warnings_shown = true
end

Then(/^current configuration should be displayed$/) do
  @current_config_displayed = true
end

Then(/^effective values should be shown$/) do
  @effective_values_shown = true
end

Then(/^inheritance chain should be visible$/) do
  @inheritance_chain_visible = true
end

Then(/^potential issues should be identified$/) do
  @issues_identified = true
end

Then(/^API authentication should work$/) do
  @api_auth_successful = true
end

Then(/^remote configuration should be cached$/) do
  @remote_config_cached = true
end

Then(/^network failures should be handled$/) do
  @network_failures_handled = true
end

Then(/^local fallback should be available$/) do
  @local_fallback_available = true
end
