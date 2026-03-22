require 'fileutils'
require 'tempfile'
require 'json'

# Global test configuration
class AicommitTestConfig
  attr_accessor :test_repo_dir, :temp_dirs, :mock_services, :exit_codes, :outputs
  
  def initialize
    @test_repo_dir = nil
    @temp_dirs = []
    @mock_services = {}
    @exit_codes = {}
    @outputs = {}
  end
  
  def cleanup
    # Clean up test repositories
    if @test_repo_dir && Dir.exist?(@test_repo_dir)
      FileUtils.rm_rf(@test_repo_dir)
    end
    
    # Clean up temporary directories
    @temp_dirs.each do |dir|
      FileUtils.rm_rf(dir) if Dir.exist?(dir)
    end
    
    # Reset environment variables
    ENV.delete('AI_BACKEND') if ENV['AI_BACKEND']
    ENV.delete('AI_MODEL') if ENV['AI_MODEL']
    ENV.delete('AI_TIMEOUT') if ENV['AI_TIMEOUT']
  end
end

# Global configuration instance
$config = AicommitTestConfig.new

# Before each scenario
Before do
  @config = $config
  @outputs = {}
  @exit_codes = {}
  
  # Create a fresh test repository for each scenario
  @config.test_repo_dir = Dir.mktmpdir('aicommit-test-repo')
  Dir.chdir(@config.test_repo_dir) do
    system('git init --quiet')
    system('git config user.name "Test User"')
    system('git config user.email "test@example.com"')
    system('git config core.excludesFile /dev/null')  # Disable global gitignore
  end
end

# After each scenario
After do
  @config.cleanup
end

# Helper methods for test setup
def create_test_repo
  repo_dir = Dir.mktmpdir('aicommit-test-repo')
  Dir.chdir(repo_dir) do
    system('git init --quiet')
    system('git config user.name "Test User"')
    system('git config user.email "test@example.com"')
    system('git config core.excludesFile /dev/null')
  end
  repo_dir
end

def stage_file(filename, content)
  File.write(filename, content)
  system("git add #{filename}")
end

def run_aicommit_command(command)
  Dir.chdir(@config.test_repo_dir) do
    output = `#{command} 2>&1`
    exit_code = $?.exitstatus
    [output, exit_code]
  end
end

def get_aicommit_temp_dir
  Dir.chdir(@config.test_repo_dir) do
    output = `bash -c 'source /Users/ram/Work/code/dev-stack/aicommit/aicommit.sh && source /Users/ram/Work/code/dev-stack/aicommit/lib/core.sh && get_aicommit_tmp_dir'`.strip
    output
  end
end

def mock_ollama_service(models: ['qwen2.5-coder:latest', 'llama3.2:latest'], available: true)
  @config.mock_services[:ollama] = {
    models: models,
    available: available,
    responses: {}
  }
end

def check_file_permissions(file_path)
  return nil unless File.exist?(file_path)
  File.stat(file_path).mode.to_s(8)[-3..-1]
end

def read_temp_file(filename)
  temp_dir = get_aicommit_temp_dir
  file_path = File.join(temp_dir, filename)
  File.exist?(file_path) ? File.read(file_path) : nil
end
