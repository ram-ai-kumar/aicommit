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
    Then it should have 700 permissions (owner-only)
    And it should not be world-readable
    And it should not be world-writable
    And it should not be world-executable

  Scenario: Sensitive .env files are excluded from AI context
    Given a .env file containing "SECRET_KEY=super_secret_value" is staged
    And a normal app.js file is staged
    When I build file context
    Then SECRET_KEY should not appear in FILE_CONTEXT
    And .env should not appear in CHANGE_STATS
    And But file count should include both files

  Scenario: Production .env files are excluded from AI context
    Given a .env.production file containing "TOKEN=abc" is staged
    And a normal code file is staged
    When I build file context
    Then TOKEN should not appear in FILE_CONTEXT
    And .env.production should not appear in CHANGE_STATS

  Scenario: Credential key files are excluded from AI context
    Given a server.key file containing private key data is staged
    And a normal app.js file is staged
    When I build file context
    Then server.key should not appear in CHANGE_STATS
    And private key content should not be exposed

  Scenario: Filter sensitive file diffs completely
    Given a .env file diff contains "PASSWORD=hunter2"
    When I filter and truncate the diff
    Then PASSWORD=hunter2 should not appear in output
    And entire .env diff should be removed

  Scenario: Reject unsupported backends explicitly
    Given AI_BACKEND is set to "malicious_backend"
    When I validate backend prerequisites
    Then validation should fail
    And error should mention "Unsupported backend"
    And no fallback should be attempted

  Scenario: Temporary directory paths are repo-scoped
    When I get aicommit temporary directory
    Then path should be unique per repository
    And path should not be global
    And path should include repository identifier

  Scenario: Dry-run creates secure context files
    Given files are staged and aicommit --dry-run is executed
    When I check temporary directory permissions
    Then FULL_PROMPT should have non-world-readable permissions
    And FILE_CONTEXT should have non-world-readable permissions
    And CHANGE_STATS should have non-world-readable permissions

  Scenario: Model listing does not expose sensitive data
    Given ollama models have sensitive IDs
    When I list available models
    Then only model names should be returned
    And model IDs should not be exposed
    And sensitive tokens should not be exposed

  Scenario: Model loadability does not expose prompt content
    Given ollama might log prompt content
    When I test model loadability
    Then prompt content should not appear in logs
    And sensitive data should not be exposed
    And debug information should be sanitized

  Scenario: Fallback model selection avoids suspicious names
    Given available models include suspicious names
    When I search for fallback model
    Then models with path traversal should be rejected
    And models with command injection should be rejected
    And only safe models should be selected

  Scenario: Model name sanitization prevents injection
    Given model name contains dangerous characters
    When I validate ollama prerequisites
    Then dangerous characters should be detected
    And validation should fail
    And injection attempts should be blocked

  Scenario: No hardcoded secrets in source code
    When I scan source code for secrets
    Then no hardcoded passwords should be found
    And no hardcoded API keys should be found
    And no hardcoded tokens should be found

  Scenario: Shell scripts have appropriate permissions
    When I check script permissions
    Then no world-writable scripts should exist
    And executable permissions should be appropriate
    And sensitive scripts should be protected

  Scenario: Input sanitization prevents command injection
    Given malicious input is provided to aicommit
    When I process the input
    Then shell metacharacters should be escaped
    And command injection should be prevented
    And input validation should occur

  Scenario: Path traversal attacks are prevented
    Given malicious file paths are provided
    When I process file paths
    Then path traversal sequences should be blocked
    And directory access should be limited
    And safe path resolution should occur

  Scenario: Environment variable exposure is limited
    Given sensitive environment variables exist
    When aicommit runs
    Then sensitive variables should not be logged
    And environment should not be exposed to AI
    And variable sanitization should occur

  Scenario: Temporary file cleanup prevents data leakage
    Given aicommit creates temporary files
    When operation completes or fails
    Then all temporary files should be cleaned up
    And no sensitive data should remain
    And cleanup should be thorough

  Scenario: Git history does not expose sensitive prompts
    Given aicommit processes sensitive changes
    When I check git history
    Then AI prompts should not be committed
    And temporary files should not be tracked
    And .gitignore should protect sensitive files

  Scenario: Network requests are limited to localhost
    Given aicommit needs to communicate with LLM
    When I check network connections
    Then only localhost connections should be made
    And no external network calls should occur
    And internet connectivity should not be required

  Scenario: Process isolation prevents privilege escalation
    Given aicommit runs with user privileges
    When I check process permissions
    Then no privilege escalation should occur
    And effective permissions should be limited
    And safe execution context should be maintained

  Scenario: Logging does not expose sensitive information
    Given aicommit processes sensitive data
    When I check log output
    Then sensitive file content should not be logged
    And API keys should not be logged
    And personal data should be redacted

  Scenario: Cache does not store sensitive information
    Given aicommit uses caching
    When I check cache contents
    Then sensitive prompts should not be cached
    And file content should not be cached
    And only non-sensitive data should be stored

  Scenario: Backup files do not contain sensitive data
    Given aicommit creates backup files
    When I check backup contents
    Then sensitive information should be excluded
    And backup permissions should be secure
    And backup cleanup should occur

  Scenario: Error messages do not leak information
    Given errors occur during processing
    When I check error messages
    Then file paths should be sanitized
    And system details should be limited
    And sensitive context should not be exposed

  Scenario: Resource limits prevent denial of service
    Given aicommit processes large inputs
    When I check resource usage
    Then memory usage should be bounded
    And CPU usage should be reasonable
    And disk usage should be limited

  Scenario: Concurrent access does not expose data
    Given multiple users run aicommit
    When I check data isolation
    Then user data should remain separate
    And temporary files should be isolated
    And no cross-user data leakage should occur
