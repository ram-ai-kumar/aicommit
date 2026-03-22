Given('I have staged changes to a JavaScript feature file') do
  @aicommit_env = setup_test_environment
  
  # Create test repository with staged changes
  create_test_git_repo
  create_staged_files('feature.js', 'function newFeature() { return true; }')
end

When('I run aicommit') do
  @result = system('./aicommit.sh', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
  @commit_message = get_last_commit_message
end

Then('it should generate a conventional commit message') do
  expect(@commit_message).to match(/^feat:/)
  expect(@commit_message).to include('newFeature')
end

Given('I have staged changes') do
  @aicommit_env = setup_test_environment
  
  # Create test repository with different staged changes
  create_staged_files('bug-fix.js', 'console.log("Fixed bug");')
end

When('I run aicommit') do
  @result = system('./aicommit.sh', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
  @commit_message = get_last_commit_message
end

Then('it should generate a bug fix commit message') do
  expect(@commit_message).to match(/^fix:/)
  expect(@commit_message).to include('Fixed bug')
end

Given('I have staged changes') do
  @aicommit_env = setup_test_environment
  
  # Create test repository with performance changes
  create_staged_files('performance.js', 'optimizeAlgorithm();')
end

When('I run aicommit') do
  @result = system('./aicommit.sh', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
  @commit_message = get_last_commit_message
end

Then('it should generate a performance improvement commit') do
  expect(@commit_message).to match(/^perf:/)
  expect(@commit_message).to include('optimizeAlgorithm')
end

Given('I have staged changes') do
  @aicommit_env = setup_test_environment
  
  # Create test repository with documentation changes
  create_staged_files('README.md', '# Updated documentation')
end

When('I run aicommit') do
  @result = system('./aicommit.sh', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
  @commit_message = get_last_commit_message
end

Then('it should generate a documentation commit message') do
  expect(@commit_message).to match(/^docs:/)
  expect(@commit_message).to include('Updated documentation')
end

Given('I have staged breaking changes') do
  @aicommit_env = setup_test_environment
  
  # Create test repository with breaking changes
  create_staged_files('api.js', 'breakingChange();')
end

When('I run aicommit') do
  @result = system('./aicommit.sh', :exit_status => $?.exit_status)
  
  expect(@result).to have_exit_status(0)
  @commit_message = get_last_commit_message
end

Then('it should generate a breaking change commit') do
  expect(@commit_message).to match(/^(feat!|fix!)/)
  expect(@commit_message).to include('BREAKING CHANGE')
end
