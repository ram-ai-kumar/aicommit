@security @critical
Feature: AI Commit Security Tests
  As a security-conscious developer
  I want aicommit to follow Zero Trust Architecture principles
  So I can trust that sensitive data remains protected

  Background:
    Given aicommit is properly installed
    And a git repository is initialized
    And the working directory is clean

  Scenario: Temporary directory has least privilege permissions
    When I create aicommit temporary directory
    And Then it should have 700 permissions (owner-only)
    And And it should not be world-readable
    And And it should not be world-writable
    And And it should not be world-executable

  Scenario: Sensitive .env files are excluded from AI context
    Given a .env file containing "SECRET_KEY=super_secret_value" is staged
    And a normal app.js file is staged
    When I build file context
    And Then SECRET_KEY should not appear in FILE_CONTEXT
    And And .env should not appear in CHANGE_STATS
    And But file count should include both files

  Scenario: Production .env files are excluded from AI context
    Given a .env.production file containing "TOKEN=abc" is staged
    And a normal code file is staged
    When I build file context
    And Then TOKEN should not appear in FILE_CONTEXT
    And And .env.production should not appear in CHANGE_STATS

  Scenario: Credential key files are excluded from AI context
    Given a server.key file containing private key data is staged
    And a normal app.js file is staged
    When I build file context
    And Then server.key should not appear in CHANGE_STATS
    And And private key content should not be exposed

  Scenario: Filter sensitive file diffs completely
    Given a .env file diff contains "PASSWORD=hunter2"
    When I filter and truncate the diff
    And Then PASSWORD=hunter2 should not appear in output
    And And entire .env diff should be removed

  Scenario: Reject unsupported backends explicitly
    Given AI_BACKEND is set to "malicious_backend"
    When I validate backend prerequisites
    And Then validation should fail
    And And error should mention "Unsupported backend"
    And And no fallback should be attempted

  Scenario: Temporary directory paths are repo-scoped
    When I get aicommit temporary directory
    And Then path should be unique per repository
    And And path should not be global
    And And path should include repository identifier

  Scenario: Dry-run creates secure context files
    Given files are staged and aicommit --dry-run is executed
    When I check temporary directory permissions
    And Then FULL_PROMPT should have non-world-readable permissions
    And And FILE_CONTEXT should have non-world-readable permissions
    And And CHANGE_STATS should have non-world-readable permissions

  Scenario: Model listing does not expose sensitive data
    Given ollama models have sensitive IDs
    When I list available models
    And Then only model names should be returned
    And And model IDs should not be exposed
    And And sensitive tokens should not be exposed

  Scenario: Model loadability does not expose prompt content
    Given ollama might log prompt content
    When I test model loadability
    And Then prompt content should not appear in logs
    And And sensitive data should not be exposed
    And And debug information should be sanitized

  Scenario: Fallback model selection avoids suspicious names
    Given available models include suspicious names
    When I search for fallback model
    And Then models with path traversal should be rejected
    And And models with command injection should be rejected
    And And only safe models should be selected

  Scenario: Model name sanitization prevents injection
    Given model name contains dangerous characters
    When I validate ollama prerequisites
    And Then dangerous characters should be detected
    And And validation should fail
    And And injection attempts should be blocked

  Scenario: No hardcoded secrets in source code
    When I scan source code for secrets
    And Then no hardcoded passwords should be found
    And And no hardcoded API keys should be found
    And And no hardcoded tokens should be found

  Scenario: Shell scripts have appropriate permissions
    When I check script permissions
    And Then no world-writable scripts should exist
    And And executable permissions should be appropriate
    And And sensitive scripts should be protected

  Scenario: Input sanitization prevents command injection
    Given malicious input is provided to aicommit
    When I process the input
    And Then shell metacharacters should be escaped
    And And command injection should be prevented
    And And input validation should occur

  Scenario: Path traversal attacks are prevented
    Given malicious file paths are provided
    When I process file paths
    And Then path traversal sequences should be blocked
    And And directory access should be limited
    And And safe path resolution should occur

  Scenario: Environment variable exposure is limited
    Given sensitive environment variables exist
    When aicommit runs
    And Then sensitive variables should not be logged
    And And environment should not be exposed to AI
    And And variable sanitization should occur

  Scenario: Temporary file cleanup prevents data leakage
    Given aicommit creates temporary files
    When operation completes or fails
    And Then all temporary files should be cleaned up
    And And no sensitive data should remain
    And And cleanup should be thorough

  Scenario: Git history does not expose sensitive prompts
    Given aicommit processes sensitive changes
    When I check git history
    And Then AI prompts should not be committed
    And And temporary files should not be tracked
    And And .gitignore should protect sensitive files

  Scenario: Network requests are limited to localhost
    Given aicommit needs to communicate with LLM
    When I check network connections
    And Then only localhost connections should be made
    And And no external network calls should occur
    And And internet connectivity should not be required

  Scenario: Process isolation prevents privilege escalation
    Given aicommit runs with user privileges
    When I check process permissions
    And Then no privilege escalation should occur
    And And effective permissions should be limited
    And And safe execution context should be maintained

  Scenario: Logging does not expose sensitive information
    Given aicommit processes sensitive data
    When I check log output
    And Then sensitive file content should not be logged
    And And API keys should not be logged
    And And personal data should be redacted

  Scenario: Cache does not store sensitive information
    Given aicommit uses caching
    When I check cache contents
    And Then sensitive prompts should not be cached
    And And file content should not be cached
    And And only non-sensitive data should be stored

  Scenario: Backup files do not contain sensitive data
    Given aicommit creates backup files
    When I check backup contents
    And Then sensitive information should be excluded
    And And backup permissions should be secure
    And And backup cleanup should occur

  Scenario: Error messages do not leak information
    Given errors occur during processing
    When I check error messages
    And Then file paths should be sanitized
    And And system details should be limited
    And And sensitive context should not be exposed

  Scenario: Resource limits prevent denial of service
    Given aicommit processes large inputs
    When I check resource usage
    And Then memory usage should be bounded
    And And CPU usage should be reasonable
    And And disk usage should be limited

  Scenario: Concurrent access does not expose data
    Given multiple users run aicommit
    When I check data isolation
    And Then user data should remain separate
    And And temporary files should be isolated
    And And no cross-user data leakage should occur
