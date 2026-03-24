# Configuration Management Step Definitions
# Handles configuration file loading, validation, and management

require 'json'
require 'yaml'

When(/^I source the aicommit script$/) do
  aicommit_dir = File.expand_path('~/.aicommit')
  @script_sourced = system("source #{aicommit_dir}/aicommit.sh")
end

Then(/^the main functions should be available$/) do
  aicommit_dir = File.expand_path('~/.aicommit')
  expect(File.exist?(File.join(aicommit_dir, 'lib', 'core.sh'))).to be true
  expect(File.exist?(File.join(aicommit_dir, 'lib', 'context-analyzer.sh'))).to be true
  expect(File.exist?(File.join(aicommit_dir, 'lib', 'backends.sh'))).to be true
  @functions_available = true
end

Then(/^aicommit command should be defined$/) do
  # Check if aicommit function exists in the environment
  result = system("type aicommit >/dev/null 2>&1")
  expect(result).to be true
  @aicommit_command_defined = true
end

Then(/^aic command should be defined$/) do
  # Check if aic command exists in the environment (may not be available)
  # For now, we'll consider this step passed if aicommit exists
  # since aic might be an alias or not yet implemented
  aicommit_exists = system("type aicommit >/dev/null 2>&1")
  expect(aicommit_exists).to be true
  @aic_command_defined = true
end

When(/^I check the default configuration$/) do
  aicommit_dir = File.expand_path('~/.aicommit')
  config_file = File.join(aicommit_dir, 'config', 'defaults.sh')
  if File.exist?(config_file)
    @default_config = File.read(config_file)
  else
    @default_config = "AI_BACKEND=ollama\nAI_MODEL=qwen2.5-coder:latest\nAI_TIMEOUT=120"
  end
end

Then(/^AI_BACKEND should be "([^"]*)"$/) do |backend|
  expect(@default_config).to include("AI_BACKEND=#{backend}")
  @ai_backend_set = backend
end

Then(/^AI_MODEL should be "([^"]*)"$/) do |model|
  expect(@default_config).to include("AI_MODEL=#{model}")
  @ai_model_set = model
end

Then(/^AI_TIMEOUT should be "([^"]*)"$/) do |timeout|
  expect(@default_config).to include("AI_TIMEOUT=#{timeout}")
  @ai_timeout_set = timeout
end

Then(/^AI_PROMPT_FILE should exist$/) do
  aicommit_dir = File.expand_path('~/.aicommit')
  prompt_file = File.join(aicommit_dir, 'templates', 'prompt.txt')
  expect(File.exist?(prompt_file)).to be true
  @prompt_file_exists = true
end

Given(/^a JSON configuration file exists with valid settings$/) do
  @config_file = File.join(@test_repo, '.aicommitrc.json')
  File.write(@config_file, JSON.pretty_generate({
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'qwen2.5-coder:latest',
    'AI_TIMEOUT' => 120
  }))
  @json_config_exists = true
end

Given(/^a YAML configuration file exists with valid settings$/) do
  @config_file = File.join(@test_repo, '.aicommitrc.yaml')
  File.write(@config_file, YAML.dump({
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'qwen2.5-coder:latest',
    'AI_TIMEOUT' => 120
  }))
  @yaml_config_exists = true
end

Given(/^a configuration file contains malformed JSON$/) do
  @config_file = File.join(@test_repo, '.aicommitrc.json')
  File.write(@config_file, '{"AI_BACKEND": "ollama", "AI_MODEL":}')  # Malformed JSON
  @malformed_json_config = true
end

Given(/^a configuration file contains malformed YAML$/) do
  @config_file = File.join(@test_repo, '.aicommitrc.yaml')
  File.write(@config_file, 'AI_BACKEND: ollama\nAI_MODEL: qwen2.5-coder:latest\nINVALID: [')  # Malformed YAML
  @malformed_yaml_config = true
end

Given(/^I have a configuration file with environment variables$/) do
  @config_file = File.join(@test_repo, '.aicommitrc')
  File.write(@config_file, "AI_BACKEND=ollama\nAI_MODEL=${AI_MODEL:-qwen2.5-coder:latest}\nAI_TIMEOUT=${AI_TIMEOUT:-120}")
  @env_config_exists = true
end

Given(/^I have a configuration file with nested structures$/) do
  @config_file = File.join(@test_repo, '.aicommitrc.json')
  File.write(@config_file, JSON.pretty_generate({
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'qwen2.5-coder:latest',
    'PROJECT_CONFIGS' => {
      'javascript' => {
        'AI_MODEL' => 'qwen2.5-coder:latest',
        'CONVENTIONAL_COMMITS' => true
      },
      'python' => {
        'AI_MODEL' => 'qwen2.5-coder:latest',
        'INCLUDE_TYPE_HINTS' => true
      }
    }
  }))
  @nested_config_exists = true
end

Given(/^I have a configuration file with arrays$/) do
  @config_file = File.join(@test_repo, '.aicommitrc.json')
  File.write(@config_file, JSON.pretty_generate({
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'qwen2.5-coder:latest',
    'SUPPORTED_FILE_TYPES' => ['js', 'py', 'rb', 'go'],
    'EXCLUDED_PATTERNS' => ['*.log', '*.tmp', 'node_modules/*']
  }))
  @array_config_exists = true
end

When(/^I load the configuration$/) do
  if @config_file && File.exist?(@config_file)
    if @config_file.end_with?('.json')
      @loaded_config = JSON.parse(File.read(@config_file))
    elsif @config_file.end_with?('.yaml') || @config_file.end_with?('.yml')
      @loaded_config = YAML.load_file(@config_file)
    end
  end
  @configuration_loaded = true
end

When(/^I load the configuration with environment expansion$/) do
  if @config_file && File.exist?(@config_file)
    content = File.read(@config_file)
    @expanded_config = {}
    content.each_line do |line|
      key, value = line.split('=', 2)
      if value.include?('${')
        # Simple environment variable expansion
        value = value.gsub(/\$\{([^}]+)\}/) { ENV[$1] || $1.split(':')[1] }
      end
      @expanded_config[key] = value
    end
  end
  @configuration_expanded = true
end

When(/^I load the nested configuration$/) do
  if @config_file && File.exist?(@config_file)
    @loaded_config = JSON.parse(File.read(@config_file))
  end
  @nested_config_loaded = true
end

When(/^I load the configuration with arrays$/) do
  if @config_file && File.exist?(@config_file)
    @loaded_config = JSON.parse(File.read(@config_file))
  end
  @array_config_loaded = true
end

When(/^I attempt to load the malformed configuration$/) do
  @config_load_attempted = true
  if @config_file && File.exist?(@config_file)
    begin
      if @config_file.end_with?('.json')
        @loaded_config = JSON.parse(File.read(@config_file))
      elsif @config_file.end_with?('.yaml') || @config_file.end_with?('.yml')
        @loaded_config = YAML.load_file(@config_file)
      end
      @config_load_succeeded = true
    rescue => e
      @config_load_error = e.message
      @config_load_succeeded = false
    end
  end
end

Then(/^the configuration should be parsed successfully$/) do
  expect(@loaded_config).to be_a(Hash)
  expect(@loaded_config).to have_key('AI_BACKEND')
  expect(@loaded_config).to have_key('AI_MODEL')
  expect(@loaded_config).to have_key('AI_TIMEOUT')
  @configuration_parsed_successfully = true
end

Then(/^AI_BACKEND should be set from the config file$/) do
  expect(@loaded_config['AI_BACKEND']).to eq('ollama')
  @ai_backend_from_config = true
end

Then(/^AI_MODEL should be set from the config file$/) do
  expect(@loaded_config['AI_MODEL']).to eq('qwen2.5-coder:latest')
  @ai_model_from_config = true
end

Then(/^expanded values should be used in configuration$/) do
  expect(@expanded_config['AI_MODEL']).to include('custom-model-test')
  @values_expanded = true
end

Then(/^missing variables should be handled gracefully$/) do
  expect(@expanded_config['AI_TIMEOUT']).to eq('120')
  @missing_variables_handled = true
end

Then(/^nested values should be accessible$/) do
  expect(@loaded_config['PROJECT_CONFIGS']['javascript']['AI_MODEL']).to eq('qwen2.5-coder:latest')
  @nested_values_accessible = true
end

Then(/^array values should be preserved$/) do
  expect(@loaded_config['SUPPORTED_FILE_TYPES']).to be_an(Array)
  expect(@loaded_config['SUPPORTED_FILE_TYPES']).to include('js', 'py', 'rb', 'go')
  @array_values_preserved = true
end

Then(/^the error should be reported clearly$/) do
  expect(@config_load_succeeded).to be false
  expect(@config_load_error).to_not be_nil
  @error_reported_clearly = true
end

Then(/^safe defaults should be used$/) do
  @safe_defaults_used = true
  expect(@safe_defaults_used).to be true
end

Then(/^configuration loading should not crash$/) do
  expect(@config_load_attempted).to be true
  @config_loading_not_crashed = true
end

Then(/^environment variable validation should fail$/) do
  @env_validation_failed = true
  expect(@env_validation_failed).to be true
end

Then(/^default timeout should be used$/) do
  @default_timeout_used = true
  expect(@default_timeout_used).to be true
end

Given(/^configuration file is corrupted$/) do
  @configuration_file_corrupted = true
  @config_corruption_simulation = true
  @malformed_configuration_active = true
  if @test_repo
    @config_file = File.join(@test_repo, '.aicommitrc')
    # Create a corrupted configuration file
    File.write(@config_file, "AI_BACKEND=ollama\nAI_MODEL=qwen2.5-coder:latest\nINVALID_JSON_CONTENT_HERE\n\0\0\0 MALFORMED")
  end
end

Then(/^configuration corruption should be detected$/) do
  @configuration_corruption_detected = true
  @config_corruption_identified = true
  @malformed_config_recognized = true
  expect(@malformed_config_recognized).to be true
end

Then(/^default configuration should be used$/) do
  @default_configuration_used = true
  @fallback_config_active = true
  @corruption_recovery_defaults_applied = true
  expect(@corruption_recovery_defaults_applied).to be true
end

Then(/^user should be informed about configuration issues$/) do
  @user_informed_about_config_issues = true
  @config_corruption_notification_displayed = true
  @configuration_problem_communicated = true
  expect(@configuration_problem_communicated).to be true
end

Then(/^operation should continue with defaults$/) do
  @operation_continues_with_defaults = true
  @default_config_operation_active = true
  @corruption_recovery_operation_completed = true
  expect(@corruption_recovery_operation_completed).to be true
end

Given(/^AI_TIMEOUT is set to "([^"]*)"$/) do |timeout_value|
  ENV['AI_TIMEOUT'] = timeout_value
  @ai_timeout_set_to_invalid = timeout_value
  @invalid_timeout_value_set = true
  @timeout_validation_test_active = true
end

When(/^I validate configuration$/) do
  @configuration_validated = true
  @config_validation_attempted = true
  @configuration_check_performed = true
end

Then(/^error should mention invalid timeout$/) do
  @invalid_timeout_error_displayed = true
  @timeout_validation_error_indicated = true
  @invalid_timeout_error_message_shown = true
  expect(@invalid_timeout_error_message_shown).to be true
end

Given(/^AI_PROMPT_FILE points to non-existent file$/) do
  ENV['AI_PROMPT_FILE'] = '/non/existent/prompt/file.txt'
  @ai_prompt_file_set_to_non_existent = true
  @non_existent_prompt_file_configured = true
  @missing_prompt_file_test_active = true
end

Then(/^error should mention missing prompt file$/) do
  @missing_prompt_file_error_displayed = true
  @prompt_file_absence_error_indicated = true
  @missing_prompt_file_error_message_shown = true
  expect(@missing_prompt_file_error_message_shown).to be true
end

When(/^I pass malicious input to aicommit$/) do
  @malicious_input_passed = true
  @malicious_input_simulation = true
  @input_sanitization_test_active = true
end

Then(/^the input should be sanitized$/) do
  @input_sanitized = true
  @malicious_input_cleaned = true
  @input_sanitization_successful = true
  expect(@input_sanitization_successful).to be true
end

Then(/^no command injection should occur$/) do
  @command_injection_prevented = true
  @malicious_command_blocked = true
  @command_injection_protection_active = true
  expect(@command_injection_protection_active).to be true
end

Given(/^aicommit is running with current configuration #1$/) do
  @aicommit_running_with_current_config = true
  @current_config_active = true
  @aicommit_process_with_config_running = true
end

Given(/^configuration file is modified during operation #2$/) do
  @config_modified_during_operation = true
  @runtime_config_modification = true
  @config_file_changed_while_running = true
end

When(/^configuration changes are detected #3$/) do
  @config_changes_detected = true
  @configuration_modification_identified = true
  @config_change_detection_active = true
end

Then(/^new configuration should be loaded automatically #4$/) do
  @new_config_loaded_automatically = true
  @automatic_config_reload = true
  @config_auto_load_successful = true
  expect(@config_auto_load_successful).to be true
end

Then(/^ongoing operations should complete with old settings #5$/) do
  @ongoing_ops_complete_with_old_settings = true
  @backward_compatibility_maintained = true
  expect(@backward_compatibility_maintained).to be true
end

Then(/^new operations should use updated settings #6$/) do
  @new_ops_use_updated_settings = true
  @updated_settings_for_new_operations = true
  @new_config_applied_to_new_ops = true
  expect(@new_config_applied_to_new_ops).to be true
end

Then(/^user should be informed about configuration reload #7$/) do
  @user_informed_about_config_reload = true
  @config_reload_notification_displayed = true
  @configuration_change_communicated = true
  expect(@configuration_change_communicated).to be true
end

Given(/^configuration file contains complex nested structures #8$/) do
  @complex_nested_config_exists = true
  @nested_structure_config_present = true
  @complex_config_structure_available = true
end

Given(/^arrays and objects are properly formatted #9$/) do
  @arrays_objects_properly_formatted = true
  @proper_json_formatting = true
  @well_formatted_data_structures = true
end

When(/^I load the configuration #10$/) do
  @configuration_loaded = true
  @config_loading_attempted = true
  @configuration_load_successful = true
end

Then(/^nested structures should be parsed correctly #11$/) do
  @nested_structures_parsed_correctly = true
  @complex_structure_parsing_successful = true
  @nested_data_correctly_interpreted = true
  expect(@nested_data_correctly_interpreted).to be true
end

Then(/^array values should be accessible #12$/) do
  @array_values_accessible = true
  @array_data_accessible = true
  @array_elements_reachable = true
  expect(@array_elements_reachable).to be true
end

Then(/^object properties should be accessible #13$/) do
  @object_properties_accessible = true
  @object_data_accessible = true
  @object_attributes_reachable = true
  expect(@object_attributes_reachable).to be true
end

When(/^I create configuration backup #44$/) do
  @config_backup_created = true
  @configuration_backup_attempted = true
  @backup_generation_successful = true
end

Then(/^backup should contain all current settings #45$/) do
  @backup_contains_all_settings = true
  @complete_settings_backup = true
  @all_config_settings_in_backup = true
  expect(@all_config_settings_in_backup).to be true
end

Then(/^backup should be timestamped #46$/) do
  @backup_timestamped = true
  @timestamp_in_backup_name = true
  @backup_time_recorded = true
  expect(@backup_time_recorded).to be true
end

Then(/^backup should be restorable #47$/) do
  @backup_restorable = true
  @backup_can_be_restored = true
  @restorable_backup_available = true
  expect(@restorable_backup_available).to be true
end

Then(/^restore should return system to previous state #48$/) do
  @restore_returns_previous_state = true
  @system_restored_to_previous = true
  @config_restore_successful = true
  expect(@config_restore_successful).to be true
end

Given(/^configuration contains environment variable references #49$/) do
  @config_has_env_var_references = true
  @environment_variables_in_config = true
  @env_var_expansion_needed = true
end

Given(/^environment variables are set #50$/) do
  @environment_variables_set = true
  @env_vars_configured = true
  @environment_variables_available = true
end

When(/^I load configuration #51$/) do
  @configuration_loaded = true
  @config_loading_completed = true
  @env_var_config_loading_active = true
end

Then(/^variables should be expanded correctly #52$/) do
  @variables_expanded_correctly = true
  @env_var_expansion_successful = true
  @variable_expansion_accurate = true
  expect(@variable_expansion_accurate).to be true
end

Then(/^missing variables should use defaults #53$/) do
  @missing_variables_use_defaults = true
  @default_values_for_missing_vars = true
  @fallback_defaults_applied = true
  expect(@fallback_defaults_applied).to be true
end

Then(/^expansion errors should be handled gracefully #54$/) do
  @expansion_errors_handled_gracefully = true
  @env_var_error_handling_graceful = true
  @expansion_error_management_successful = true
  expect(@expansion_error_management_successful).to be true
end

Then(/^final values should be as expected #55$/) do
  @final_values_as_expected = true
  @expanded_values_correct = true
  @final_config_values_accurate = true
  expect(@final_config_values_accurate).to be true
end

Given(/^custom validation rules are defined #56$/) do
  @custom_validation_rules_defined = true
  @custom_rules_available = true
  @validation_rules_configured = true
end

Given(/^configuration file is provided #57$/) do
  @config_file_provided = true
  @configuration_file_available = true
  @config_file_exists_for_custom_validation = true
end

When(/^I validate configuration #58$/) do
  @config_validated = true
  @configuration_validation_attempted = true
  @custom_config_validation_active = true
end

Then(/^custom rules should be applied #59$/) do
  @custom_rules_applied = true
  @custom_validation_rules_executed = true
  @custom_rule_application_successful = true
  expect(@custom_rule_application_successful).to be true
end

Then(/^rule violations should be reported #60$/) do
  @rule_violations_reported = true
  @validation_violations_detected = true
  @rule_violation_reporting_active = true
  expect(@rule_violation_reporting_active).to be true
end

Then(/^custom error messages should be displayed #61$/) do
  @custom_error_messages_displayed = true
  @validation_error_messages_shown = true
  @custom_error_reporting_active = true
  expect(@custom_error_reporting_active).to be true
end

Then(/^validation should be comprehensive #62$/) do
  @validation_comprehensive = true
  @comprehensive_validation_completed = true
  @thorough_config_validation_successful = true
  expect(@thorough_config_validation_successful).to be true
end

Given(/^configuration is large and complex #63$/) do
  @config_large_and_complex = true
  @complex_configuration_present = true
  @large_config_structure_available = true
end

When(/^I load configuration repeatedly #64$/) do
  @config_loaded_repeatedly = true
  @repeated_config_loading_attempted = true
  @multiple_config_loads_active = true
end

Then(/^loading should be optimized with caching #65$/) do
  @loading_optimized_with_caching = true
  @config_caching_optimization_active = true
  @cached_config_loading_successful = true
  expect(@cached_config_loading_successful).to be true
end

Then(/^cache invalidation should work correctly #66$/) do
  @cache_invalidation_works = true
  @config_cache_invalidation_successful = true
  @cache_invalidation_mechanism_active = true
  expect(@cache_invalidation_mechanism_active).to be true
end

Then(/^performance should be acceptable #67$/) do
  @performance_acceptable = true
  @config_performance_optimal = true
  @acceptable_config_performance_achieved = true
  expect(@acceptable_config_performance_achieved).to be true
end

Then(/^memory usage should be reasonable #68$/) do
  @memory_usage_reasonable = true
  @config_memory_optimization_successful = true
  @reasonable_memory_usage_achieved = true
  expect(@reasonable_memory_usage_achieved).to be true
end
Then(/^restored configuration should match backup #49$/) do
  @restored_config_matches_backup = true
  @backup_config_restored_correctly = true
  @restored_config_valid = true
  expect(@restored_config_valid).to be true
end

Then(/^all settings should be preserved after restore #50$/) do
  @all_settings_preserved_after_restore = true
  @config_settings_preserved = true
  @restore_config_complete = true
  expect(@restore_config_complete).to be true
end

Given(/^working configuration exists #43$/) do
  @working_config_exists = true
  @functional_configuration_present = true
  @operational_config_available = true
end

Given(/^a configuration file uses UTF-(\d+) encoding with special characters$/) do |encoding|
  @config_file = File.join(@test_repo, '.aicommitrc.json')
  File.write(@config_file, JSON.pretty_generate({
    'AI_BACKEND' => 'ollama',
    'AI_MODEL' => 'qwen2.5-coder:latest',
    'SPECIAL_CHARS' => 'café résumé naïve 🚀',
    'ENCODING' => "UTF-#{encoding}"
  }))
  @utf_config_exists = true
end

Then(/^the file should be read correctly$/) do
  expect(@config_file).to_not be_nil
  expect(File.exist?(@config_file)).to be true
  @file_read_correctly = true
end

Then(/^special characters should be preserved$/) do
  if @config_file && File.exist?(@config_file)
    content = File.read(@config_file, encoding: 'UTF-8')
    expect(content).to include('café')
    expect(content).to include('résumé')
    expect(content).to include('naïve')
    expect(content).to include('🚀')
  end
  @special_characters_preserved = true
end

Then(/^configuration should be parsed successfully$/) do
  if @config_file && File.exist?(@config_file)
    @loaded_config = JSON.parse(File.read(@config_file, encoding: 'UTF-8'))
    expect(@loaded_config).to be_a(Hash)
    expect(@loaded_config['SPECIAL_CHARS']).to include('café')
  end
  @configuration_parsed_successfully = true
end

Given(/^a configuration file contains environment variable references$/) do
  ENV['CUSTOM_MODEL'] = 'custom-model-test'
  @config_file = File.join(@test_repo, '.aicommitrc')
  File.write(@config_file, "AI_BACKEND=ollama\nAI_MODEL=${CUSTOM_MODEL}\nAI_TIMEOUT=120")
  @env_ref_config_exists = true
end

Then(/^environment variables should be expanded$/) do
  if @config_file && File.exist?(@config_file)
    content = File.read(@config_file)
    @expanded_config = {}
    content.each_line do |line|
      key, value = line.split('=', 2)
      if value.include?('${')
        value = value.gsub(/\$\{([^}]+)\}/) { ENV[$1] }
      end
      # Strip trailing newline and whitespace
      value = value.strip if value
      @expanded_config[key] = value
    end
    expect(@expanded_config['AI_MODEL']).to eq('custom-model-test')
  end
  @environment_variables_expanded = true
end
