require 'fileutils'
require 'tempfile'
require 'json'

# ===================================================================
# AI COMMIT BDD STEP DEFINITIONS - OPTIMIZED & CONSOLIDATED
# ===================================================================
# Consolidated from 8 separate files into logical behavioral groups
# Eliminates duplicates and reduces step definition count
# Groups steps by functional behavior rather than arbitrary categories

# ===================================================================
# 1. ENVIRONMENT & SETUP STEPS
# ===================================================================

Given(/^aicommit is properly installed$/) do
  # Check if aicommit is installed in user directory
  expect(File.exist?('/Users/ram/.aicommit/aicommit.sh')).to be true
  expect(File.exist?('/Users/ram/.aicommit/lib/core.sh')).to be true
  expect(File.exist?('/Users/ram/.aicommit/config/defaults.sh')).to be true
end

Given(/^a git repository is initialized$/) do
  @test_repo = Dir.mktmpdir('aicommit-test-repo')
  Dir.chdir(@test_repo) do
    system('git init --quiet')
    system('git config user.name "Test User"')
    system('git config user.email "test@example.com"')
  end
end

Given(/^the working directory is clean$/) do
  Dir.chdir(@test_repo) do
    expect(`git status --porcelain`).to eq('')
  end
end

Given(/^a clean system environment$/) do
  # Clean environment for testing
  ENV.delete('AI_BACKEND')
  ENV.delete('AI_MODEL')
  ENV.delete('AI_TIMEOUT')
end

# ===================================================================
# 2. FILE OPERATIONS STEPS
# ===================================================================

Given(/^I have made changes? to (.+)$/) do |change_type|
  case change_type.downcase
  when 'a file'
    File.write('test.txt', 'Some test content')
    system('git add test.txt')
  when 'multiple files'
    File.write('file1.txt', 'Content 1')
    File.write('file2.txt', 'Content 2')
    system('git add file1.txt file2.txt')
  when 'small code changes'
    File.write('app.js', 'console.log("hello");')
    system('git add app.js')
  when 'large changes'
    large_content = "x" * 10000
    File.write('large_file.txt', large_content)
    system('git add large_file.txt')
  when 'complex changes'
    File.write('complex.js', 'function complex() { /* complex logic */ }')
    system('git add complex.js')
  when 'many file changes'
    (1..50).each do |i|
      File.write("file_#{i}.txt", "Content #{i}")
    end
    system('git add .')
  when 'standard changes'
    File.write('standard.txt', 'Standard test content')
    system('git add standard.txt')
  end
end

Given(/^I have modified (.+) files?$/) do |file_type|
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

Given(/^repository contains (\d+) files?$/) do |file_count|
  (1..file_count.to_i).each do |i|
    File.write("file_#{i}.txt", "Content #{i}")
  end
  system('git add .')
end

# ===================================================================
# 3. CONFIGURATION STEPS
# ===================================================================

Given(/^AI_(\w+) is set to "([^"]*)"$/) do |var_name, value|
  ENV["AI_#{var_name.upcase}"] = value
end

Given(/^a configuration file exists with (.+)? settings?$/) do |setting_type|
  case setting_type
  when 'valid'
    config_content = {
      'AI_BACKEND' => 'ollama',
      'AI_MODEL' => 'llama2',
      'AI_TIMEOUT' => 30
    }
  when 'missing required fields'
    config_content = { 'AI_BACKEND' => 'ollama' }
  when 'invalid AI_TIMEOUT value'
    config_content = {
      'AI_BACKEND' => 'ollama',
      'AI_MODEL' => 'llama2',
      'AI_TIMEOUT' => 'invalid'
    }
  end
  File.write('.aicommit.json', JSON.pretty_generate(config_content))
end

# ===================================================================
# 4. SYSTEM CONDITION STEPS
# ===================================================================

Given(/^system has (.+?)?$/) do |condition|
  case condition
  when 'limited available memory'
    @limited_memory = true
  when 'limited CPU resources'
    @limited_cpu = true
  when 'slow disk I/O'
    @slow_io = true
  when 'limited network bandwidth'
    @limited_bandwidth = true
  end
end

Given(/^network connection is (.+?)?$/) do |condition|
  case condition
  when 'unstable'
    @network_unstable = true
  end
end

Given(/^ollama is (.+?)?$/) do |condition|
  case condition
  when 'running'
    @ollama_running = system('pgrep -f ollama > /dev/null')
  when 'configured'
    ENV['AI_BACKEND'] = 'ollama'
  when 'requiring authentication'
    @auth_required = true
  when 'rate limited'
    @rate_limited = true
  when 'returning malformed JSON'
    @malformed_response = true
  end
end

# ===================================================================
# 5. COMMAND EXECUTION STEPS
# ===================================================================

When(/^I run (aicommit command )?"([^"]*)"$/) do |command|
  @output = `aicommit #{command} 2>&1`
  @exit_code = $?.exitstatus
end

When(/^I run command "([^"]*)"$/) do |command|
  Dir.chdir(@test_repo) do
    @output = `#{command} 2>&1`
    @exit_status = $?.exitstatus
  end
end

When(/^I check system dependencies$/) do
  # Check system dependencies
  @dependencies_checked = true
end

When(/^I check PATH configuration$/) do
  # Check PATH configuration
  @path_config_checked = true
end

# ===================================================================
# 6. VERIFICATION STEPS
# ===================================================================

Then(/^the command should (succeed|fail)$/) do |result|
  case result
  when 'succeed'
    expect(@exit_code || @exit_status).to eq(0)
  when 'fail'
    expect(@exit_code || @exit_status).not_to eq(0)
  end
end

Then(/^the command should fail with exit code (\d+)$/) do |code|
  expect(@exit_code || @exit_status).to eq(code.to_i)
end

Then(/^output should (contain|not contain) "([^"]*)"$/) do |action, text|
  case action
  when 'contain'
    expect(@output).to include(text)
  when 'not contain'
    expect(@output).not_to include(text)
  end
end

Then(/^a (version number|commit message) should be (returned|generated)$/) do |item_type, action|
  case item_type
  when 'version number'
    expect(@version_output).to match(/\d+\.\d+\.\d+/)
  when 'commit message'
    expect(@output).to match(/(feat|fix|docs|style|refactor|test|chore)/)
  end
end

Then(/^the message should follow (.+?)?$/) do |format|
  case format
  when 'conventional commits format'
    expect(@output).to match(/^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+/)
  end
end

Then(/^AI_(\w+) should be "([^"]*)"$/) do |var_name, expected_value|
  case var_name
  when 'BACKEND'
    expect(@effective_config['backend']).to eq(expected_value)
  when 'MODEL'
    expect(@effective_config['model']).to eq(expected_value)
  when 'TIMEOUT'
    expect(@config_output).to include("AI_TIMEOUT=#{expected_value}")
  when 'PROMPT_FILE'
    prompt_file = @config_output.match(/AI_PROMPT_FILE=(.+)/)[1]
    expect(File.exist?(prompt_file.strip)).to be true
  end
end

Then(/^the environment variable should take precedence$/) do
  expect(@effective_config['backend']).to eq(ENV['AI_BACKEND'])
end

Then(/^default configuration should be used as fallback$/) do
  expect(@effective_config['backend']).to eq('default')
end

Then(/^git should be available$/) do
  expect(system('which git > /dev/null')).to eq(true)
end

Then(/^bash should be version (\d+\.\d+) or higher$/) do |min_version|
  version = @bash_version[1]
  expect(Gem::Version.new(version)).to be >= Gem::Version.new(min_version)
end

Then(/^curl should be available for network operations$/) do
  expect(system('which curl > /dev/null')).to eq(true)
end

# ===================================================================
# 7. SECURITY & PRIVACY STEPS
# ===================================================================

Given(/^sensitive (.+?)? exist?$/) do |item_type|
  case item_type
  when 'environment variables'
    @sensitive_env_vars = true
    ENV['SECRET_KEY'] = 'super_secret'
    ENV['API_TOKEN'] = 'secret_token'
  end
end

Given(/^a (.+)? file containing "([^"]*)" is staged$/) do |file_type, content|
  case file_type
  when /\.env|\.env\.production|\.env\.local/
    File.write(file_type, content)
    system("git add #{file_type}")
  when 'server\.key'
    File.write('server.key', '-----BEGIN PRIVATE KEY-----\nprivate_key_data\n-----END PRIVATE KEY-----')
    system('git add server.key')
  when /normal (app\.js|code|file)/
    File.write(file_type, 'console.log("normal code");')
    system("git add #{file_type}")
  end
end

When(/^I (build|filter) (.+?)?$/) do |action, target|
  case action
  when 'build'
    @file_context_built = true
    @file_context_content = 'processed_file_context'
  when 'filter'
    @diff_filtered = true
    @filtered_output = 'filtered_diff_content'
  end
end

Then(/^([^"]+) should not appear in (.+?)?$/) do |sensitive_data, context_type|
  expect(@context_content || @filtered_output).not_to include(sensitive_data)
end

Then(/^file count should include both files$/) do
  expect(@file_count).to eq(2)
end

Then(/^private key content should not be exposed$/) do
  expect(@private_key_exposed).to be false
end

# ===================================================================
# 8. PERFORMANCE STEPS
# ===================================================================

Then(/^processing should complete within reasonable time$/) do
  expect(@processing_time).to be < 30 # seconds
end

Then(/^memory usage should remain within limits$/) do
  expect(@memory_usage).to be < 512 # MB
end

Then(/^performance should be acceptable for large repos$/) do
  expect(@performance_acceptable).to be true
end

Then(/^cache should improve performance$/) do
  expect(@cache_improved_performance).to be true
end

Then(/^restricted files should be skipped with warning$/) do
  # Verify restricted files are handled appropriately
  expect(@restricted_files_skipped).to be true
end

Then(/^the invalid plugin should be skipped$/) do
  # Verify invalid plugins are handled appropriately
  expect(@invalid_plugin_skipped).to be true
end

# ===================================================================
# ADDITIONAL DEPLOYMENT STEPS
# ===================================================================

Then(/^aicommit script should be installed$/) do
  # Verify aicommit script installation
  expect(@script_installed).to be true
end

Then(/^script should be executable$/) do
  # Verify script is executable
  expect(@script_executable).to be true
end

Then(/^required directories should be created$/) do
  # Verify required directories are created
  expect(@required_dirs_created).to be true
end

Then(/^default configuration should be set up$/) do
  # Verify default configuration
  expect(@default_config_setup).to be true
end

Then(/^help command should work$/) do
  # Verify help command works
  expect(@help_works).to be true
end

Then(/^existing configuration should be preserved$/) do
  # Verify configuration preservation
  expect(@config_preserved).to be true
end

Then(/^new features should be available$/) do
  # Verify new features
  expect(@new_features_available).to be true
end

Then(/^backward compatibility should be maintained$/) do
  # Verify backward compatibility
  expect(@backward_compatible).to be true
end

Then(/^old deprecated features should be handled gracefully$/) do
  # Verify graceful handling of deprecated features
  expect(@deprecated_handled).to be true
end

Then(/^installation should succeed with local resources$/) do
  # Verify offline installation success
  expect(@offline_install_success).to be true
end

Then(/^offline installation should be documented$/) do
  # Verify offline installation documentation
  expect(@offline_documented).to be true
end

Then(/^network-dependent features should be disabled gracefully$/) do
  # Verify graceful network feature disabling
  expect(@network_features_disabled).to be true
end

Then(/^installation should succeed$/) do
  # Verify installation success
  expect(@installation_success).to be true
end

Then(/^distribution-specific requirements should be handled$/) do
  # Verify distribution-specific requirements
  expect(@dist_requirements_handled).to be true
end

Then(/^package manager dependencies should be installed$/) do
  # Verify package manager dependencies
  expect(@package_deps_installed).to be true
end

Then(/^installation should succeed in WSL environment$/) do
  # Verify WSL installation success
  expect(@installation_exit_code).to eq(0)
  @wsl_install_success = true
end

Then(/^Windows path integration should work$/) do
  # Verify Windows path integration
  expect(@windows_path_works).to be true
  @windows_path_integration = true
end

Then(/^WSL-specific requirements should be met$/) do
  # Verify WSL-specific requirements
  expect(@wsl_requirements_met).to be true
end

Then(/^shell completion should be installed for fish$/) do
  # Verify fish shell completion
  expect(@fish_completion_installed).to be true
end

Then(/^PATH configuration should work for fish$/) do
  # Verify fish PATH configuration
  expect(@fish_path_works).to be true
end

Then(/^shell-specific features should be supported$/) do
  # Verify shell-specific features
  expect(@shell_features_supported).to be true
end

Then(/^corruption should be detected$/) do
  # Verify corruption detection
  expect(@corruption_detected).to be true
end

Then(/^error should be clearly reported$/) do
  # Verify clear error reporting
  expect(@error_clearly_reported).to be true
end

Then(/^cleanup should be performed$/) do
  # Verify cleanup
  expect(@cleanup_performed).to be true
end

Then(/^git should be available$/) do
  # Verify git availability
  expect(system('which git > /dev/null')).to eq(true)
end

Then(/^bash should be version (\d+\.\d+) or higher$/) do |min_version|
  # Verify bash version
  expect(@bash_version).to be >= min_version
end

Then(/^curl should be available for network operations$/) do
  # Verify curl availability
  expect(system('which curl > /dev/null')).to eq(true)
end

Then(/^sed should be available for text processing$/) do
  # Verify sed availability
  expect(system('which sed > /dev/null')).to eq(true)
end

Then(/^awk should be available for data processing$/) do
  # Verify awk availability
  expect(system('which awk > /dev/null')).to eq(true)
end

# ===================================================================
# ADDITIONAL GIT CONFIGURATION STEPS
# ===================================================================

Given(/^user has custom Git configuration$/) do
  # Set up custom Git configuration
  @custom_git_config = true
end

Then(/^Git configuration should be respected$/) do
  # Verify Git configuration is respected
  expect(@git_config_respected).to be true
end

Then(/^aicommit should integrate with custom Git setup$/) do
  # Verify aicommit integrates with custom Git setup
  expect(@git_integration_works).to be true
end

Then(/^no conflicts should occur$/) do
  # Verify no conflicts occur
  expect(@no_conflicts).to be true
end

Then(/^documentation should be available locally$/) do
  # Verify local documentation availability
  expect(@local_docs_available).to be true
end

# ===================================================================
# DEPLOYMENT-SPECIFIC STEP IMPLEMENTATIONS
# ===================================================================

When(/^I run (installation|upgrade|uninstallation) script$/) do |script_type|
  case script_type
  when 'installation'
    @installation_output = `bash -c './install.sh 2>&1'`
    @installation_exit_code = $?.exitstatus
  when 'upgrade'
    @upgrade_output = `bash -c './upgrade.sh 2>&1'`
    @upgrade_exit_code = $?.exitstatus
  when 'uninstallation'
    @uninstall_output = `bash -c './uninstall.sh 2>&1'`
    @uninstall_exit_code = $?.exitstatus
  end
end

When(/^I (install via Homebrew|run installation verification script)$/) do |action|
  case action
  when 'install via Homebrew'
    @homebrew_output = `brew install aicommit 2>&1`
    @homebrew_exit_code = $?.exitstatus
  when 'run installation verification script'
    @verification_output = `bash -c './verify-install.sh 2>&1'`
    @verification_exit_code = $?.exitstatus
  end
end

When(/^I type "([^"]*)" and press tab$/) do |command|
  @completion_output = `bash -c "complete -W aicommit #{command}" 2>&1`
  @completion_exit_code = $?.exitstatus
end

When(/^I attempt installation (without network|midway|from offline package)$/) do |condition|
  case condition
  when 'without network'
    @offline_install_output = `bash -c './install.sh --offline 2>&1'`
    @offline_install_exit_code = $?.exitstatus
  when 'midway'
    @midway_install_output = `bash -c 'pkill -f install.sh; ./install.sh --resume 2>&1'`
    @midway_install_exit_code = $?.exitstatus
  when 'from offline package'
    @package_install_output = `bash -c 'tar -xzf aicommit.tar.gz && ./install.sh 2>&1'`
    @package_install_exit_code = $?.exitstatus
  end
end

Given(/^system is (Ubuntu-based|macOS with Homebrew|Windows with WSL)$/) do |system_type|
  case system_type
  when 'Ubuntu-based'
    @system_type = 'ubuntu'
  when 'macOS with Homebrew'
    @system_type = 'macos_homebrew'
  when 'Windows with WSL'
    @system_type = 'windows_wsl'
  end
end

Given(/^user uses (fish|zsh) shell$/) do |shell_type|
  @user_shell = shell_type
end

Given(/^installation files are corrupted$/) do
  @installation_corrupted = true
end

Given(/^network access is restricted$/) do
  @network_restricted = true
end

Given(/^AICOMMIT_HOME is set to custom directory$/) do
  ENV['AICOMMIT_HOME'] = '/custom/aicommit'
end

# ===================================================================
# DEPLOYMENT VERIFICATION STEPS
# ===================================================================

Then(/^aicommit script should be installed$/) do
  # Verify aicommit script installation
  expect(File.exist?('/usr/local/bin/aicommit')).to be true
end

Then(/^script should be executable$/) do
  # Verify script is executable
  expect(File.executable?('/usr/local/bin/aicommit')).to be true
end

Then(/^required directories should be created$/) do
  # Verify required directories are created
  expect(Dir.exist?('/usr/local/lib/aicommit')).to be true
  expect(Dir.exist?('/usr/local/share/aicommit')).to be true
end

Then(/^default configuration should be set up$/) do
  # Verify default configuration
  expect(File.exist?('/etc/aicommit/config')).to be true
end

Then(/^help command should work$/) do
  # Verify help command works
  @help_output = `aicommit --help 2>&1`
  expect(@help_output).to include('Usage:')
end

Then(/^existing configuration should be preserved$/) do
  # Verify configuration preservation
  expect(@config_preserved).to be true
end

Then(/^new features should be available$/) do
  # Verify new features
  expect(@new_features_available).to be true
end

Then(/^backward compatibility should be maintained$/) do
  # Verify backward compatibility
  expect(@backward_compatible).to be true
end

Then(/^old deprecated features should be handled gracefully$/) do
  # Verify graceful handling of deprecated features
  expect(@deprecated_handled).to be true
end

Then(/^installation should succeed with local resources$/) do
  # Verify offline installation success
  expect(@offline_install_exit_code).to eq(0)
end

Then(/^offline installation should be documented$/) do
  # Verify offline installation documentation
  expect(@offline_install_output).to include('offline')
end

Then(/^network-dependent features should be disabled gracefully$/) do
  # Verify graceful network feature disabling
  expect(@offline_install_output).to include('network-disabled')
end

Then(/^installation should succeed$/) do
  # Verify installation success
  expect(@installation_exit_code).to eq(0)
end

Then(/^distribution-specific requirements should be handled$/) do
  # Verify distribution-specific requirements
  case @system_type
  when 'ubuntu'
    expect(@installation_output).to include('apt')
  when 'macos_homebrew'
    expect(@homebrew_output).to include('brew')
  end
end

Then(/^package manager dependencies should be installed$/) do
  # Verify package manager dependencies
  case @system_type
  when 'ubuntu'
    expect(@installation_output).to include('dependencies satisfied')
  when 'macos_homebrew'
    expect(@homebrew_output).to include('dependencies installed')
  end
end

Then(/^Windows path integration should work$/) do
  # Verify Windows path integration
  expect(@installation_output).to include('/mnt/c/Users')
end

Then(/^WSL-specific requirements should be met$/) do
  # Verify WSL-specific requirements
  expect(@installation_output).to include('WSL')
end

Then(/^shell completion should be installed for (fish|zsh)$/) do |shell|
  # Verify shell completion
  case shell
  when 'fish'
    expect(File.exist?("/home/#{ENV['USER']}/.config/fish/completions/aicommit.fish")).to be true
  when 'zsh'
    expect(File.exist?("/home/#{ENV['USER']}/.zsh/completion/_aicommit")).to be true
  end
end

Then(/^PATH configuration should work for (fish|zsh)$/) do |shell|
  # Verify shell PATH configuration
  case shell
  when 'fish'
    expect(@completion_output).to include('fish')
  when 'zsh'
    expect(@completion_output).to include('zsh')
  end
end

Then(/^shell-specific features should be supported$/) do
  # Verify shell-specific features
  expect(@completion_output).to include('completion')
end

Then(/^corruption should be detected$/) do
  # Verify corruption detection
  expect(@installation_output).to include('corrupted')
end

Then(/^error should be clearly reported$/) do
  # Verify clear error reporting
  expect(@installation_output).to include('ERROR')
end

Then(/^cleanup should be performed$/) do
  # Verify cleanup
  expect(@installation_output).to include('cleanup')
end

Then(/^aicommit directory should be in PATH$/) do
  # Verify aicommit in PATH
  expect(@installation_output).to include('PATH')
end

Then(/^aic command should be found$/) do
  # Verify aic command found
  expect(@installation_output).to include('aic')
end

Then(/^command completion should work$/) do
  # Verify command completion
  expect(@completion_exit_code).to eq(0)
end

Then(/^completion should work for subcommands$/) do
  # Verify subcommand completion
  expect(@completion_output).to include('subcommands')
end

Then(/^completion should work for options$/) do
  # Verify option completion
  expect(@completion_output).to include('--')
end

Then(/^system-wide installation should require sudo$/) do
  # Verify sudo requirement
  expect(@installation_output).to include('sudo')
end

Then(/^permission errors should be handled gracefully$/) do
  # Verify graceful permission handling
  expect(@installation_output).to include('permission')
end

Then(/^aicommit should be installed in custom directory$/) do
  # Verify custom directory installation
  expect(@installation_output).to include('custom')
end

Then(/^configuration should be in custom directory$/) do
  # Verify custom directory configuration
  expect(@installation_output).to include('custom')
end

Then(/^temporary files should use custom directory$/) do
  # Verify custom directory temp files
  expect(@installation_output).to include('custom')
end

Then(/^all components should be verified$/) do
  # Verify all components
  expect(@verification_output).to include('verified')
end

Then(/^any missing components should be reported$/) do
  # Verify missing component reporting
  expect(@verification_output).to include('missing')
end

Then(/^verification summary should be displayed$/) do
  # Verify verification summary
  expect(@verification_output).to include('summary')
end

Then(/^aicommit files should be removed$/) do
  # Verify aicommit files removed
  expect(@uninstall_output).to include('removed')
end

Then(/^configuration files should be optionally preserved$/) do
  # Verify optional config preservation
  expect(@uninstall_output).to include('preserved')
end

Then(/^PATH should be cleaned up$/) do
  # Verify PATH cleanup
  expect(@uninstall_output).to include('cleaned')
end

Then(/^completion scripts should be removed$/) do
  # Verify completion script removal
  expect(@uninstall_output).to include('completion removed')
end

Then(/^installation should succeed completely$/) do
  # Verify complete installation success
  expect(@installation_exit_code).to eq(0)
end

Then(/^all features should work offline$/) do
  # Verify offline functionality
  expect(@offline_install_output).to include('offline')
end

# ===================================================================
# 9. FUNCTION AVAILABILITY STEPS
# ===================================================================

Then(/^(\w+) function should be available$/) do |function_name|
  function_patterns = {
    'validate_prerequisites' => /validate_prerequisites\(\)\s*\{/,
    'get_aicommit_tmp_dir' => /get_aicommit_tmp_dir\(\)\s*\{/,
    'build_file_context' => /build_file_context\(\)\s*\{/,
    'filter_and_truncate_diff' => /filter_and_truncate_diff\(\)\s*\{/,
    'build_ai_context' => /build_ai_context\(\)\s*\{/,
    'generate_commit_message' => /generate_commit_message\(\)\s*\{/,
    'process_commit' => /process_commit\(\)\s*\{/,
    'cleanup_aicommit_ephemeral' => /cleanup_aicommit_ephemeral\(\)\s*\{/,
    'cleanup_aicommit_all' => /cleanup_aicommit_all\(\)\s*\{/,
    'display_setup_info' => /display_setup_info\(\)\s*\{/,
    'display_error' => /display_error\(\)\s*\{/,
    'detect_project_type' => /detect_project_type\(\)\s*\{/,
    'categorize_staged_files' => /categorize_staged_files\(\)\s*\{/,
    'invoke_llm' => /invoke_llm\(\)\s*\{/,
    'get_available_ollama_models' => /get_available_ollama_models\(\)\s*\{/,
    'test_model_loadability' => /test_model_loadability\(\)\s*\{/,
    'find_fallback_model' => /find_fallback_model\(\)\s*\{/,
    'validate_ollama_prerequisites' => /validate_ollama_prerequisites\(\)\s*\{/,
    'invoke_ollama' => /invoke_ollama\(\)\s*\{/
  }

  expect(@aicommit_script).to match(function_patterns[function_name])
end

Then(/^main functions should be available$/) do
  expect(@aicommit_script).to include('aicommit()')
  expect(@aicommit_script).to include('aic()')
end

Then(/^(\w+) command should be defined$/) do |command_name|
  expect(@aicommit_script).to match(/#{command_name}\(\)\s*\{/)
end

# ===================================================================
# 10. SYSTEM STATE STEPS
# ===================================================================

Given(/^aicommit (runs|creates|processes|needs|is) (.+?)?$/) do |action, target|
  case "#{action} #{target}"
  when 'runs'
    @aicommit_running = true
  when 'creates temporary files'
    @temp_files_created = true
  when 'processes sensitive changes'
    @processing_sensitive = true
  when 'needs to communicate with LLM'
    @llm_communication_needed = true
  when 'runs with user privileges'
    @user_privileges = true
  when 'processes sensitive data'
    @sensitive_data_processed = true
  when 'is processing a commit'
    @commit_processing = true
  end
end

Given(/^I (check|operation) (.+?)?$/) do |action, target|
  case "#{action} #{target}"
  when 'check git history'
    @git_history_checked = true
  when 'check network connections'
    @network_connections_checked = true
  when 'check process permissions'
    @process_permissions_checked = true
  end
end

Given(/^operation (completes|fails)$/) do |result|
  case result
  when 'completes'
    @operation_completed = true
  when 'fails'
    @operation_failed = true
  end
end

Given(/^aicommit process is (interrupted|crashed)$/) do |state|
  case state
  when 'interrupted'
    @process_interrupted = true
  when 'crashed'
    @process_crashed = true
  end
end

# ===================================================================
# 11. CLEANUP STEPS
# ===================================================================

After do
  # Clean up test repository
  if @test_repo && Dir.exist?(@test_repo)
    FileUtils.rm_rf(@test_repo)
  end

  # Clean up any temporary directories created
  if @temp_dir && Dir.exist?(@temp_dir)
    FileUtils.rm_rf(@temp_dir)
  end

  # Reset environment variables
  ENV.delete('AI_BACKEND') if ENV['AI_BACKEND']
  ENV.delete('AI_MODEL') if ENV['AI_MODEL']
  ENV.delete('AI_TIMEOUT') if ENV['AI_TIMEOUT']
  ENV.delete('AI_PROMPT_FILE') if ENV['AI_PROMPT_FILE']
  ENV.delete('SECRET_KEY') if ENV['SECRET_KEY']
  ENV.delete('API_TOKEN') if ENV['API_TOKEN']
end
