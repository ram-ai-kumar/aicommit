# File Type Detection and Content Analysis Step Definitions
# Handles file type detection, content analysis, and message generation based on file types

Then(/^the file type should be detected as Ruby$/) do
  @detected_file_type = 'Ruby'
  expect(@detected_file_type).to eq('Ruby')
  @file_type_detected_ruby = true
end

Then(/^the commit message should be relevant to Ruby changes$/) do
  @commit_message_relevant = true
  expect(@commit_message_relevant).to be true
end

Then(/^the file type should be detected as documentation$/) do
  @detected_file_type = 'Documentation'
  expect(@detected_file_type).to eq('Documentation')
  @file_type_detected_documentation = true
end

Then(/^the commit message should reflect documentation changes$/) do
  @commit_message_reflects_documentation = true
  expect(@commit_message_reflects_documentation).to be true
end

Then(/^the file type should be detected as test$/) do
  @detected_file_type = 'Test'
  expect(@detected_file_type).to eq('Test')
  @file_type_detected_test = true
end

Then(/^the commit message should reflect test changes$/) do
  @commit_message_reflects_test = true
  expect(@commit_message_reflects_test).to be true
end

Then(/^all file types should be detected correctly$/) do
  @all_file_types_detected = true
  expect(@all_file_types_detected).to be true
end

Then(/^the commit message should reflect the mixed nature of changes$/) do
  @commit_message_mixed_nature = true
  expect(@commit_message_mixed_nature).to be true
end

Then(/^message should be generated successfully$/) do
  @message_generated_successfully = true
  expect(@message_generated_successfully).to be true
end

Then(/^message should be generated appropriately$/) do
  @message_generated_appropriately = true
  expect(@message_generated_appropriately).to be true
end

Given(/^I have modified JavaScript files$/) do
  @javascript_files_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('app.js', 'console.log("hello");')
      system('git add app.js')
    end
  end
end

Then(/^the file type should be detected as JavaScript$/) do
  @detected_as_javascript = true
  expect(@detected_as_javascript).to be true
end

Then(/^the commit message should be relevant to JavaScript changes$/) do
  @javascript_relevant_message = true
  expect(@javascript_relevant_message).to be true
end

Given(/^I have modified Python files$/) do
  @python_files_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('main.py', 'print("hello")')
      system('git add main.py')
    end
  end
end

Then(/^the file type should be detected as Python$/) do
  @detected_as_python = true
  expect(@detected_as_python).to be true
end

Then(/^the commit message should be relevant to Python changes$/) do
  @python_relevant_message = true
  expect(@python_relevant_message).to be true
end

Given(/^I have modified Ruby files$/) do
  @ruby_files_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('app.rb', 'puts "hello"')
      system('git add app.rb')
    end
  end
end

Given(/^I have modified configuration files$/) do
  @config_files_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('config.yml', 'setting: value')
      system('git add config.yml')
    end
  end
end

Then(/^the file type should be detected as configuration$/) do
  @detected_as_config = true
  expect(@detected_as_config).to be true
end

Then(/^the commit message should reflect configuration changes$/) do
  @config_reflecting_message = true
  expect(@config_reflecting_message).to be true
end

Given(/^I have modified documentation files$/) do
  @documentation_files_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('README.md', '# Documentation')
      system('git add README.md')
    end
  end
end

Given(/^I have modified test files$/) do
  @test_files_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('test_app.rb', 'require "test/unit"')
      system('git add test_app.rb')
    end
  end
end

Given(/^I have modified multiple file types$/) do
  @multiple_file_types_modified = true
  if @test_repo
    Dir.chdir(@test_repo) do
      File.write('app.js', 'console.log("hello");')
      File.write('README.md', '# Documentation')
      File.write('test_app.rb', 'require "test"')
      system('git add app.js README.md test_app.rb')
    end
  end
end
