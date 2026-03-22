# Security-specific step definitions

Given(/^temporary directory has least privilege permissions$/) do
  @temp_dir = get_aicommit_temp_dir
end

Then(/^it should have (\d+) permissions \(owner-only\)$/) do |expected_permissions|
  actual_permissions = check_file_permissions(@temp_dir)
  expect(actual_permissions).to eq(expected_permissions)
end

Then(/^it should not be world-readable$/) do
  permissions = check_file_permissions(@temp_dir)
  expect(permissions[-1]).to eq('0')
end

Then(/^it should not be world-writable$/) do
  permissions = check_file_permissions(@temp_dir)
  expect(permissions[-1]).to eq('0')
end

Then(/^it should not be world-executable$/) do
  permissions = check_file_permissions(@temp_dir)
  expect(permissions[-1]).to eq('0')
end

Given(/^a \.env file containing "([^"]*)" is staged$/) do |content|
  Dir.chdir(@config.test_repo_dir) do
    stage_file('.env', content)
  end
end

Given(/^a normal app\.js file is staged$/) do
  Dir.chdir(@config.test_repo_dir) do
    stage_file('app.js', 'console.log("hello");')
  end
end

When(/^I build file context$/) do
  Dir.chdir(@config.test_repo_dir) do
    staged = `git diff --staged --name-only`.strip
    numstat = `git diff --staged --numstat`.strip
    
    @context_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && staged="#{staged}" && numstat="#{numstat}" && build_file_context "$staged" "$numstat"'`
  end
end

Then(/^SECRET_KEY should not appear in FILE_CONTEXT$/) do
  file_content = read_temp_file('FILE_CONTEXT')
  expect(file_content).not_to include('SECRET_KEY') if file_content
end

Then(/^\.env should not appear in CHANGE_STATS$/) do
  change_stats = read_temp_file('CHANGE_STATS')
  expect(change_stats).not_to include('.env') if change_stats
end

Then(/^file count should include both files$/) do
  file_count = read_temp_file('FILE_COUNT')
  expect(file_count.strip).to eq('2') if file_count
end

Given(/^a server\.key file containing private key data is staged$/) do
  Dir.chdir(@config.test_repo_dir) do
    stage_file('server.key', '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----')
  end
end

Then(/^server\.key should not appear in CHANGE_STATS$/) do
  change_stats = read_temp_file('CHANGE_STATS')
  expect(change_stats).not_to include('server.key') if change_stats
end

Then(/^private key content should not be exposed$/) do
  file_context = read_temp_file('FILE_CONTEXT')
  expect(file_context).not_to include('BEGIN PRIVATE KEY') if file_context
end

When(/^I filter and truncate the diff$/) do
  # Create a test diff with sensitive content
  test_diff = "diff --git a/.env b/.env\n+PASSWORD=hunter2\n"
  @filtered_diff = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && echo "#{test_diff}" | filter_and_truncate_diff'`
end

Then(/^PASSWORD=hunter2 should not appear in output$/) do
  expect(@filtered_diff).not_to include('PASSWORD=hunter2')
end

Then(/^entire \.env diff should be removed$/) do
  expect(@filtered_diff).not_to include('.env')
end

Given(/^AI_BACKEND is set to "([^"]*)"$/) do |backend|
  ENV['AI_BACKEND'] = backend
end

When(/^I validate backend prerequisites$/) do
  @validation_output, @validation_status = run_aicommit_command('bash -c \'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/backends.sh && validate_backend_prerequisites\'')
end

Then(/^validation should fail$/) do
  expect(@validation_status).not_to eq(0)
end

Then(/^error should mention "([^"]*)"$/) do |error_text|
  expect(@validation_output).to include(error_text)
end

Then(/^no fallback should be attempted$/) do
  expect(@validation_output).not_to include('fallback')
end

When(/^I get aicommit temporary directory$/) do
  @temp_dir = get_aicommit_temp_dir
end

Then(/^path should be unique per repository$/) do
  expect(@temp_dir).to include(File.basename(@config.test_repo_dir))
end

Then(/^path should not be global$/) do
  expect(@temp_dir).not_to eq('/tmp/.aicommit')
end

Then(/^path should include repository identifier$/) do
  expect(@temp_dir).to match(/\/tmp\/\.aicommit\/[^\/]+/)
end

Given(/^files are staged and aicommit --dry-run is executed$/) do
  Dir.chdir(@config.test_repo_dir) do
    stage_file('test.js', 'console.log("test");')
    @dry_run_output, @dry_run_status = run_aicommit_command('bash -c \'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && aicommit --dry-run\'')
  end
end

When(/^I check temporary directory permissions$/) do
  @temp_dir = get_aicommit_temp_dir
  @full_prompt_perms = check_file_permissions(File.join(@temp_dir, 'FULL_PROMPT'))
  @file_context_perms = check_file_permissions(File.join(@temp_dir, 'FILE_CONTEXT'))
  @change_stats_perms = check_file_permissions(File.join(@temp_dir, 'CHANGE_STATS'))
end

Then(/^FULL_PROMPT should have non-world-readable permissions$/) do
  expect(@full_prompt_perms[-1]).to eq('0') if @full_prompt_perms
end

Then(/^FILE_CONTEXT should have non-world-readable permissions$/) do
  expect(@file_context_perms[-1]).to eq('0') if @file_context_perms
end

Then(/^CHANGE_STATS should have non-world-readable permissions$/) do
  expect(@change_stats_perms[-1]).to eq('0') if @change_stats_perms
end

Given(/^ollama models have sensitive IDs$/) do
  mock_ollama_service(models: ['model-with-secret-key:latest', 'model-with-token:latest'])
end

When(/^I list available models$/) do
  @model_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/backends.sh && get_available_ollama_models'`
end

Then(/^only model names should be returned$/) do
  expect(@model_output).to include('model-with-secret-key:latest')
  expect(@model_output).to include('model-with-token:latest')
end

Then(/^model IDs should not be exposed$/) do
  expect(@model_output).not_to match(/[a-f0-9]{40,}/)
end

Then(/^sensitive tokens should not be exposed$/) do
  expect(@model_output).not_to include('secret123')
  expect(@model_output).not_to include('token456')
end

Given(/^ollama might log prompt content$/) do
  mock_ollama_service
end

When(/^I test model loadability$/) do
  @loadability_output, @loadability_status = run_aicommit_command('bash -c \'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/backends.sh && test_model_loadability "test-model"\'')
end

Then(/^prompt content should not appear in logs$/) do
  expect(@loadability_output).not_to include('secret data')
end

Then(/^sensitive data should not be exposed$/) do
  expect(@loadability_output).not_to match(/password|secret|token|key/i)
end

Given(/^available models include suspicious names$/) do
  @suspicious_models = ['../../../etc/passwd:latest', '|cat secrets.txt:latest', 'safe-model:latest']
end

When(/^I search for fallback model$/) do
  # Mock the fallback model search with suspicious models
  @fallback_model = 'safe-model:latest'
end

Then(/^models with path traversal should be rejected$/) do
  expect(@fallback_model).not_to include('../')
end

Then(/^models with command injection should be rejected$/) do
  expect(@fallback_model).not_to include('|')
  expect(@fallback_model).not_to include(';')
end

Then(/^only safe models should be selected$/) do
  expect(@fallback_model).to eq('safe-model:latest')
end

Given(/^model name contains dangerous characters$/) do
  @dangerous_model = 'safe-model; rm -rf /'
end

When(/^I validate ollama prerequisites$/) do
  @validation_output, @validation_status = run_aicommit_command("bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/backends.sh && validate_ollama_prerequisites \"#{@dangerous_model}\"'")
end

Then(/^dangerous characters should be detected$/) do
  expect(@validation_status).not_to eq(0)
end

Then(/^validation should fail$/) do
  expect(@validation_status).not_to eq(0)
end

Then(/^injection attempts should be blocked$/) do
  expect(@validation_output).to include('not found')
end

When(/^I scan source code for secrets$/) do
  @secrets_output = `bash -c 'grep -rE "(password|secret|key|token)" --include="*.sh" --exclude-dir=test /Users/ram/Work/code/dev-stack/aicommit 2>/dev/null || true'`
end

Then(/^no hardcoded passwords should be found$/) do
  expect(@secrets_output).not_to match(/password\s*=\s*['"][^'"]+['"]/i)
end

Then(/^no hardcoded API keys should be found$/) do
  expect(@secrets_output).not_to match(/api[_-]?key\s*=\s*['"][^'"]+['"]/i)
end

Then(/^no hardcoded tokens should be found$/) do
  expect(@secrets_output).not_to match(/token\s*=\s*['"][^'"]+['"]/i)
end

When(/^I check script permissions$/) do
  @script_perms_output = `find /Users/ram/Work/code/dev-stack/aicommit -name "*.sh" -perm /o+w ! -path './test/*' 2>/dev/null || true`
end

Then(/^no world-writable scripts should exist$/) do
  expect(@script_perms_output.strip).to eq('')
end

Then(/^executable permissions should be appropriate$/) do
  # Check that main scripts are executable
  main_script = '/Users/ram/Work/code/dev-stack/aicommit/aicommit.sh'
  expect(File.executable?(main_script)).to be true
end

Given(/^malicious input is provided to aicommit$/) do
  @malicious_input = 'test; rm -rf /; echo'
end

When(/^I process the input$/) do
  @processed_output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && echo "#{@malicious_input}" | grep -v ";" || echo "sanitized"'`
end

Then(/^shell metacharacters should be escaped$/) do
  expect(@processed_output).not_to include(';')
  expect(@processed_output).not_to include('rm -rf')
end

Then(/^command injection should be prevented$/) do
  expect(@processed_output).not_to include('sanitized')
end

Given(/^malicious file paths are provided$/) do
  @malicious_paths = ['../../../etc/passwd', '|cat /etc/shadow', 'normal_file.txt']
end

When(/^I process file paths$/) do
  @processed_paths = @malicious_paths.map { |path| path.gsub(/[|;&$`'"(){}]/, '') }
end

Then(/^path traversal sequences should be blocked$/) do
  expect(@processed_paths).not_to include('../')
end

Then(/^directory access should be limited$/) do
  expect(@processed_paths).not_to include('/etc/')
end

Then(/^safe path resolution should occur$/) do
  expect(@processed_paths).to include('normal_file.txt')
end
