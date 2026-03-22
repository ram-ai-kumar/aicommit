Given('I have aicommit installed') do
  @aicommit_env = setup_test_environment
  
  # Clean up any previous test state
  cleanup_test_environment
end

Given('I have an unsupported LLM backend configured') do
  @aicommit_env = setup_test_environment
  
  # Configure unsupported backend
  export AI_BACKEND="unsupported-backend"
end

When('I attempt to run aicommit') do
  @result = system('./aicommit.sh --dry-run 2>&1', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(1)
  expect(@result).to include('Backend validation should fail explicitly')
  expect(@result).to include('no source code should be processed')
end

Then('backend validation should fail explicitly') do
  expect(@result).to include('Unsupported backend')
  expect(@result).to include('Please configure a valid backend')
  expect(@result).to include('Supported backends: ollama, llamacpp, localai')
end

Then('no source code should be processed') do
  # Verify that no git operations were performed
  expect(@result).not_to include('git add')
  expect(@result).not_to include('git commit')
end

Given('I have a git repository with staged changes') do
  @aicommit_env = setup_test_environment
  
  # Create test repository with staged changes
  create_test_git_repo
  create_staged_files
end

When('I run aicommit --dry-run') do
  @result = system('./aicommit.sh --dry-run 2>&1', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
end

Then('no sensitive content should reach any backend') do
  # Check that sensitive files were excluded
  prompt_file = get_aicommit_tmp_dir.join('FULL_PROMPT')
  expect(File.exist?(prompt_file)).to be false
  
  # Verify no sensitive content in prompt
  expect(@result).not_to include('.env')
  expect(@result).not_to include('SECRET_KEY')
  expect(@result).not_to include('password')
end

Then('all temporary files should have restricted permissions') do
  # Check temporary directory permissions
  temp_dir = get_aicommit_tmp_dir
  expect(File.exist?(temp_dir)).to be true
  
  # Verify 700 permissions
  expect(File.stat(temp_dir).mode.to_s(8)[3,4,5]).to eq('700')
end

Given('I have read-only file permissions') do
  @aicommit_env = setup_test_environment
  
  # Set read-only permissions
  FileUtils.chmod(get_aicommit_tmp_dir, 0o444)
end

When('I attempt to run aicommit') do
  @result = system('./aicommit.sh --dry-run 2>&1', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
end

Then('it should Work correctly') do
  expect(@result).to have_exit_status(0)
end

Then('no elevated permissions should be required') do
  # Verify no elevated permissions were needed
  expect(@result).to have_exit_status(0)
end
