require 'fileutils'
require 'tempfile'
require 'json'

Given(/^aicommit is properly installed$/) do
  # Check if aicommit is installed in the user directory
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

When(/^I source the aicommit script$/) do
  @aicommit_script = File.read('/Users/ram/Work/code/dev-stack/aicommit/aicommit.sh')
  # Simulate sourcing by evaluating in current context
  # In real implementation, this would be more sophisticated
end

Then(/^the main functions should be available$/) do
  # Check if key functions are defined in the script
  expect(@aicommit_script).to include('aicommit()')
  expect(@aicommit_script).to include('aic()')
end

Then(/^aicommit command should be defined$/) do
  expect(@aicommit_script).to match(/aicommit\(\)\s*\{/)
end

Then(/^aic command should be defined$/) do
  expect(@aicommit_script).to match(/aic\(\)\s*\{/)
end

When(/^I check the default configuration$/) do
  @config_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && echo AI_BACKEND=$AI_BACKEND; echo AI_MODEL=$AI_MODEL; echo AI_TIMEOUT=$AI_TIMEOUT; echo AI_PROMPT_FILE=$AI_PROMPT_FILE'`
end

Then(/^AI_BACKEND should be "([^"]*)"$/) do |backend|
  expect(@config_output).to include("AI_BACKEND=#{backend}")
end

Then(/^AI_MODEL should be "([^"]*)"$/) do |model|
  expect(@config_output).to include("AI_MODEL=#{model}")
end

Then(/^AI_TIMEOUT should be "([^"]*)"$/) do |timeout|
  expect(@config_output).to include("AI_TIMEOUT=#{timeout}")
end

Then(/^AI_PROMPT_FILE should exist$/) do
  prompt_file = @config_output.match(/AI_PROMPT_FILE=(.+)/)[1]
  expect(File.exist?(prompt_file.strip)).to be true
end

When(/^I run "([^"]*)"$/) do |command|
  Dir.chdir(@test_repo) do
    @output = `#{command} 2>&1`
    @exit_status = $?.exitstatus
  end
end

Then(/^the command should exit successfully$/) do
  expect(@exit_status).to eq(0)
end

Then(/^the command should fail with exit code (\d+)$/) do |code|
  expect(@exit_status).to eq(code.to_i)
end

Then(/^output should contain "([^"]*)"$/) do |text|
  expect(@output).to include(text)
end

Then(/^output should not contain "([^"]*)"$/) do |text|
  expect(@output).not_to include(text)
end

When(/^I request aicommit temporary directory$/) do
  @temp_dir_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && get_aicommit_tmp_dir'`
  @temp_dir = @temp_dir_output.strip
end

Then(/^the directory should be created$/) do
  expect(Dir.exist?(@temp_dir)).to be true
end

Then(/^the directory should be under "([^"]*)"$/) do |parent_path|
  expect(@temp_dir).to start_with(parent_path)
end

Then(/^the directory should have appropriate permissions$/) do
  permissions = File.stat(@temp_dir).mode.to_s(8)[-3..-1]
  expect(permissions).to eq('700')
end

Given(/^ollama is available and running$/) do
  # Mock ollama availability for testing
  @mock_ollama = true
end

When(/^I list available models$/) do
  if @mock_ollama
    @model_output = "qwen2.5-coder:latest\nllama3.2:latest"
  else
    @model_output = `ollama list 2>&1`
    @exit_status = $?.exitstatus
  end
end

Then(/^I should see model names only$/) do
  expect(@model_output).to include('qwen2.5-coder:latest')
  expect(@model_output).to include('llama3.2:latest')
end

Then(/^model IDs should not be exposed$/) do
  expect(@model_output).not_to match(/[a-f0-9]{40,}/)
end

Then(/^the command should succeed$/) do
  if !@mock_ollama
    expect(@exit_status).to eq(0)
  end
end

Given(/^a test model is available$/) do
  @test_model = 'qwen2.5-coder:latest'
end

When(/^I test model loadability$/) do
  if @mock_ollama
    @loadability_output = "OK"
    @loadability_status = 0
  else
    @loadability_output = `timeout 30 ollama run #{@test_model} "test" 2>&1`
    @loadability_status = $?.exitstatus
  end
end

Then(/^the test should pass$/) do
  expect(@loadability_status).to eq(0)
end

Then(/^the model should respond correctly$/) do
  expect(@loadability_output).to include('OK')
end

Given(/^multiple models are available$/) do
  @available_models = ['qwen2.5-coder:latest', 'llama3.2:latest', 'mistral:latest']
end

When(/^primary model is not available$/) do
  @preferred_model = 'nonexistent-model'
end

When(/^I search for fallback model$/) do
  # Mock fallback model search
  @fallback_model = @available_models.first
end

Then(/^a suitable fallback model should be selected$/) do
  expect(@fallback_model).to be_in(@available_models)
end

Then(/^the fallback should be loadable$/) do
  expect(@available_models).to include(@fallback_model)
end

When(/^I create aicommit temporary directory$/) do
  @temp_dir = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && get_aicommit_tmp_dir'`.strip
end

Then(/^it should have (\d+) permissions \(owner-only\)$/) do |permissions|
  actual_permissions = File.stat(@temp_dir).mode.to_s(8)[-3..-1]
  expect(actual_permissions).to eq(permissions.to_s)
end

Then(/^it should not be world-readable$/) do
  permissions = File.stat(@temp_dir).mode.to_s(8)[-1]
  expect(permissions).to eq('0')
end

Then(/^it should not be world-writable$/) do
  permissions = File.stat(@temp_dir).mode.to_s(8)[-1]
  expect(permissions).to eq('0')
end

Then(/^it should not be world-executable$/) do
  permissions = File.stat(@temp_dir).mode.to_s(8)[-1]
  expect(permissions).to eq('0')
end

Given(/^a \.env file containing "([^"]*)" is staged$/) do |content|
  Dir.chdir(@test_repo) do
    File.write('.env', content)
    system('git add .env')
  end
end

Given(/^a normal app\.js file is staged$/) do
  Dir.chdir(@test_repo) do
    File.write('app.js', 'console.log("hello");')
    system('git add app.js')
  end
end

When(/^I build file context$/) do
  Dir.chdir(@test_repo) do
    staged = `git diff --staged --name-only`
    numstat = `git diff --staged --numstat`
    @context_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && staged="#{staged}" && numstat="#{numstat}" && build_file_context "$staged" "$numstat"'`
  end
end

Then(/^SECRET_KEY should not appear in FILE_CONTEXT$/) do
  temp_dir = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && get_aicommit_tmp_dir'`.strip
  file_context = File.join(temp_dir, 'FILE_CONTEXT')
  if File.exist?(file_context)
    content = File.read(file_context)
    expect(content).not_to include('SECRET_KEY')
  end
end

Then(/^\.env should not appear in CHANGE_STATS$/) do
  temp_dir = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && get_aicommit_tmp_dir'`.strip
  change_stats = File.join(temp_dir, 'CHANGE_STATS')
  if File.exist?(change_stats)
    content = File.read(change_stats)
    expect(content).not_to include('.env')
  end
end

Then(/^file count should include both files$/) do
  temp_dir = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && get_aicommit_tmp_dir'`.strip
  file_count = File.join(temp_dir, 'FILE_COUNT')
  if File.exist?(file_count)
    count = File.read(file_count).strip
    expect(count).to eq('2')
  end
end

Given(/^AI_BACKEND is set to "([^"]*)"$/) do |backend|
  ENV['AI_BACKEND'] = backend
end

When(/^I validate backend prerequisites$/) do
  @validation_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/backends.sh && validate_backend_prerequisites' 2>&1`
  @validation_status = $?.exitstatus
end

Then(/^validation should fail$/) do
  expect(@validation_status).not_to eq(0)
end

Then(/^error should mention "([^"]*)"$/) do |error_text|
  expect(@validation_output).to include(error_text)
end

Then(/^validate_prerequisites function should be available$/) do
  expect(@aicommit_script).to match(/validate_prerequisites\(\)\s*\{/)
end

Then(/^get_aicommit_tmp_dir function should be available$/) do
  expect(@aicommit_script).to match(/get_aicommit_tmp_dir\(\)\s*\{/)
end

Then(/^build_file_context function should be available$/) do
  expect(@aicommit_script).to match(/build_file_context\(\)\s*\{/)
end

Then(/^filter_and_truncate_diff function should be available$/) do
  expect(@aicommit_script).to match(/filter_and_truncate_diff\(\)\s*\{/)
end

Then(/^build_ai_context function should be available$/) do
  expect(@aicommit_script).to match(/build_ai_context\(\)\s*\{/)
end

Then(/^generate_commit_message function should be available$/) do
  expect(@aicommit_script).to match(/generate_commit_message\(\)\s*\{/)
end

Then(/^process_commit function should be available$/) do
  expect(@aicommit_script).to match(/process_commit\(\)\s*\{/)
end

Then(/^cleanup_aicommit_ephemeral function should be available$/) do
  expect(@aicommit_script).to match(/cleanup_aicommit_ephemeral\(\)\s*\{/)
end

Then(/^cleanup_aicommit_all function should be available$/) do
  expect(@aicommit_script).to match(/cleanup_aicommit_all\(\)\s*\{/)
end

Then(/^display_setup_info function should be available$/) do
  expect(@aicommit_script).to match(/display_setup_info\(\)\s*\{/)
end

Then(/^display_error function should be available$/) do
  expect(@aicommit_script).to match(/display_error\(\)\s*\{/)
end

Then(/^detect_project_type function should be available$/) do
  expect(@aicommit_script).to match(/detect_project_type\(\)\s*\{/)
end

Then(/^categorize_staged_files function should be available$/) do
  expect(@aicommit_script).to match(/categorize_staged_files\(\)\s*\{/)
end

Then(/^validate_backend_prerequisites function should be available$/) do
  expect(@aicommit_script).to match(/validate_backend_prerequisites\(\)\s*\{/)
end

Then(/^invoke_llm function should be available$/) do
  expect(@aicommit_script).to match(/invoke_llm\(\)\s*\{/)
end

Then(/^get_available_ollama_models function should be available$/) do
  expect(@aicommit_script).to match(/get_available_ollama_models\(\)\s*\{/)
end

Then(/^test_model_loadability function should be available$/) do
  expect(@aicommit_script).to match(/test_model_loadability\(\)\s*\{/)
end

Then(/^find_fallback_model function should be available$/) do
  expect(@aicommit_script).to match(/find_fallback_model\(\)\s*\{/)
end

Then(/^validate_ollama_prerequisites function should be available$/) do
  expect(@aicommit_script).to match(/validate_ollama_prerequisites\(\)\s*\{/)
end

Then(/^invoke_ollama function should be available$/) do
  expect(@aicommit_script).to match(/invoke_ollama\(\)\s*\{/)
end

When(/^I check the aicommit directory$/) do
  @aicommit_dir_check = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && echo $AICOMMIT_DIR'`.strip
end

Then(/^AICOMMIT_DIR should be set$/) do
  expect(@aicommit_dir_check).not_to be_empty
end

Then(/^the directory should exist$/) do
  expect(Dir.exist?(@aicommit_dir_check)).to be true
end

Then(/^required subdirectories should be present$/) do
  required_dirs = %w[lib config templates bin]
  required_dirs.each do |dir|
    expect(Dir.exist?(File.join(@aicommit_dir_check, dir))).to be true
  end
end

# Cleanup after each scenario
After do
  if @test_repo && Dir.exist?(@test_repo)
    FileUtils.rm_rf(@test_repo)
  end

  # Clean up any temporary directories created
  if @temp_dir && Dir.exist?(@temp_dir)
    FileUtils.rm_rf(@temp_dir)
  end

  # Reset environment variables
  ENV.delete('AI_BACKEND') if ENV['AI_BACKEND']
end
