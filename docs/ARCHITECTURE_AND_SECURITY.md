# Architecture and Security Design

> Technical reference for aicommit internals, system design, and security framework. For the project overview, see [main README](../README.md).

## Overview

This document covers the complete technical architecture, system design, and security framework for the aicommit project, including component interactions, data flows, and security principles.

## 🔒 Security by Design

`aicommit` was built from the ground up with the premise that **source code is sensitive intellectual property**. Any tooling that processes source code must be subjected to rigorous security and privacy constraints to prevent data exfiltration, credential leaks, and supply chain attacks.

### Core Security & Privacy Principles

#### 100% Local Execution

The primary attack surface of traditional AI coding assistants is the transmission of proprietary source code to cloud APIs. AI Commit fundamentally neutralizes this risk by running all LLM inference locally. There are **zero network calls** to external AI providers (such as OpenAI, Anthropic, or GitHub Copilot).

#### Secret & Credential Filtering

Even within a local environment, care is taken to not process sensitive information unnecessarily. AI Commit incorporates intelligent filtering that specifically excludes files likely to contain secrets (`.env` files, credentials, keys) from the AI's context window.

#### Ephemeral State Management

AI Commit relies on temporary files to pass context to the LLM. These files are:

1. Created with strict permissions (700)
2. Kept localized and ephemeral
3. Automatically destroyed upon successful completion or interruption
4. The system includes an uninstaller (`uninstall.sh`) that guarantees no orphaned configuration files

### Zero Trust Architecture

AI Commit implements a Zero Trust philosophy, removing any implicit trust in third-party services, external networks, or even local temporary states.

- **Never trust, always verify:** External dependencies are validated before every invocation
- **Assume breach:** Source code **never** leaves the local device, making MITM attacks structurally impossible
- **Least Privilege:** Read-only access to `git diff` outputs, no elevated permissions or API keys
- **Micro-segmentation:** Temporary files are strictly scoped and isolated per repository

### Threat Model & Mitigations

| Threat                 | Description                                  | Mitigation Strategy                                                |
| :--------------------- | :------------------------------------------- | :----------------------------------------------------------------- |
| **Data Exfiltration**  | Accidental upload of proprietary source code | Complete reliance on local LLM runtimes, no external communication |
| **Credential Leakage** | Passwords in staging area processed by model | Proactive omission of environment files from AI context            |
| **Vendor Lock-in**     | Third-party services requiring API tokens    | No API keys needed, uses local binaries and ports                  |
| **Denial of Service**  | Large diffs causing environment hangs        | Configurable timeouts for all operations (Git, LLM, filesystem)    |
| **Telemetry Abuse**    | Unwanted data collection                     | Zero telemetry, tracking, or phone-home capabilities               |

### Compliance and Governance

AI Commit enforces organizational standards by generating precise, machine-parseable **Conventional Commits**, enabling compliance with:

- **SOC 2 (CC8.1 - Change Management):** Structured, typed commit messages org-wide
- **ISO 27001 (A.12.1.2 - Change Management):** Standardized and traceable change documentation
- **GDPR:** Data minimization and local processing
- **Industry Standards:** Consistent commit formatting across projects

## 🏗️ High-Level Architecture

```
~/.aicommit/
├── aicommit.sh              # Entry point (sourced by .zshrc)
├── bin/
│   ├── aicommit             # Standalone executable
│   └── aic                  # Quick-commit executable
├── lib/
│   ├── core.sh              # LLM integration + prompt assembly
│   ├── context-analyzer.sh  # Project type + change analysis
│   ├── backends.sh          # AI backend integration
│   └── output-formatter.sh  # Display helpers
├── config/
│   └── defaults.sh          # Default configuration
├── templates/
│   ├── prompt.txt           # LLM prompt template
│   └── conventional-commits.md
├── completions/
│   ├── _aicommit            # Zsh completions
│   └── aicommit.bash        # Bash completions
├── install.sh
└── uninstall.sh
```

### Component Map

```
  ┌─────────────────────────────────────────────────────────────┐
  │  WHAT YOU RUN                                               │
  │                                                             │
  │    aicommit ─── review message before committing            │
  │    aic ──────── commit immediately                          │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  WHAT IT DOES                                               │
  │                                                             │
  │    1. Reads your staged git changes                         │
  │    2. Analyzes project type and change patterns             │
  │    3. Builds a prompt with context and rules      ◄──┐      │
  │    4. Asks the local LLM to write the commit message │      │
```

### Core Components

#### 1. AI Commit Script (`aicommit.sh`)

- **Purpose**: Main entry point and orchestration script
- **Language**: Bash shell script
- **Responsibilities**:
  - Environment setup and configuration loading
  - Git integration and diff analysis
  - AI backend communication
  - Output formatting and user interaction

#### 2. Library Functions (`lib/`)

- **core.sh**: Core business logic and commit message generation
- **backends.sh**: AI backend integration (Ollama, OpenAI, etc.)
- **context-analyzer.sh**: Git diff analysis and context building
- **output-formatter.sh**: Result formatting and display

#### 3. Configuration Management (`config/`)

- **defaults.sh**: Default configuration values
- **User config**: `~/.aicommitrc` for user customizations
- **Environment variables**: Runtime configuration override

#### 4. Templates (`templates/`)

- **prompt.txt**: AI model prompt template
- **Custom prompts**: User-defined prompt templates

### Data Flow Architecture

```
Git Repository → Diff Analysis → Context Building → AI Backend → Message Generation → Output Formatting
```

1. **Git Integration**: Analyze staged changes and generate diff
2. **Context Analysis**: Build context from file types, changes, and history
3. **AI Communication**: Send context to AI backend for message generation
4. **Result Processing**: Format and display generated commit message

### Backend Architecture

#### Supported AI Backends

- **Ollama**: Local LLM inference (primary)
- **OpenAI**: GPT models (fallback)
- **Custom**: Extensible backend system

#### Backend Selection Logic

1. Check configured backend preference
2. Verify backend availability
3. Fallback to alternative if primary unavailable
4. Graceful degradation with user notification

## 🔒 Security Architecture

### Zero Trust Principles

The aicommit project follows Zero Trust Architecture principles:

#### 1. Never Trust, Always Verify

- All inputs are validated and sanitized
- Backend connections are authenticated
- File permissions are strictly enforced

#### 2. Least Privilege Access

- Temporary files use restrictive permissions (700)
- No unnecessary system access
- Minimal external dependencies

#### 3. Assume Breach

- Sensitive data is filtered from AI prompts
- Temporary files are securely cleaned up
- Audit trails are maintained

### Security Controls

#### Data Protection

- **Sensitive File Detection**: Automatically identifies and filters sensitive files (.env, .key, .pem, etc.)
- **Content Filtering**: Removes passwords, API keys, and secrets from AI prompts
- **Temporary File Security**: Uses secure permissions and automatic cleanup

#### Privacy Protection

- **Local Processing**: Prefers local AI backends (Ollama) for data privacy
- **No Data Retention**: Temporary files are cleaned after processing
- **User Control**: Users can configure privacy settings

#### Input Validation

- **Path Traversal Protection**: Prevents directory traversal attacks
- **Command Injection Prevention**: Sanitizes all user inputs
- **File Type Validation**: Validates file types before processing

### Threat Model

#### Identified Threats

1. **Data Exfiltration**: Sensitive code exposed to AI backends
2. **Command Injection**: Malicious input executing system commands
3. **Path Traversal**: Accessing files outside intended scope
4. **Privilege Escalation**: Gaining elevated system access
5. **Information Disclosure**: Leaking system information in error messages

#### Mitigation Strategies

1. **Data Filtering**: Comprehensive sensitive data detection and removal
2. **Input Sanitization**: Strict validation of all user inputs
3. **Path Validation**: Secure file path handling
4. **Permission Controls**: Restrictive file and directory permissions
5. **Error Handling**: Secure error message generation

### Compliance Considerations

#### GDPR Compliance

- **Data Minimization**: Only necessary data is processed
- **User Consent**: Clear disclosure of data processing
- **Right to Erasure**: Automatic cleanup of temporary data
- **Data Portability**: User can export their configuration

#### SOC 2 Compliance

- **Security Controls**: Comprehensive security framework
- **Availability**: Reliable and consistent service
- **Processing Integrity**: Accurate and complete processing
- **Confidentiality**: Protection of sensitive information

## 🔧 Technical Implementation

### Error Handling Strategy

#### Graceful Degradation

- **Backend Failures**: Fallback to alternative backends
- **Network Issues**: Local processing when possible
- **Invalid Input**: Helpful error messages and suggestions

#### Recovery Mechanisms

- **Automatic Retry**: Configurable retry logic for transient failures
- **State Recovery**: Resume interrupted operations
- **Cleanup Procedures**: Ensure system cleanup on errors

### Performance Considerations

#### Optimization Strategies

- **Caching**: Cache AI responses for similar changes
- **Parallel Processing**: Parallel file analysis when possible
- **Resource Management**: Efficient memory and CPU usage

#### Scalability Design

- **Modular Architecture**: Easy to extend with new features
- **Configuration Flexibility**: Adaptable to different environments
- **Backend Abstraction**: Support for multiple AI providers

### Monitoring and Observability

#### Logging Strategy

- **Structured Logging**: Consistent log format for analysis
- **Security Events**: Log security-relevant events
- **Performance Metrics**: Track response times and success rates

#### Debugging Support

- **Verbose Mode**: Detailed debugging information
- **Dry Run**: Preview changes without committing
- **Configuration Validation**: Verify setup before processing

## 🚀 Deployment Architecture

### Installation Methods

#### System Installation

- **Global Install**: System-wide availability
- **User Install**: Per-user installation
- **Portable**: Standalone operation without installation

#### Configuration Management

- **Environment Variables**: Runtime configuration
- **Configuration Files**: Persistent settings
- **Command Line Options**: Per-execution overrides

### Integration Points

#### Git Integration

- **Git Hooks**: Pre-commit integration
- **Workflow Integration**: CI/CD pipeline compatibility
- **Editor Integration**: IDE and editor plugins

#### AI Backend Integration

- **Local Backends**: Ollama and other local LLMs
- **Cloud Backends**: OpenAI, Anthropic, and cloud providers
- **Custom Backends**: Extensible backend system

## 📊 Architecture Evolution

### Current State

- **Version**: 1.x
- **Architecture**: Monolithic shell script with modular libraries
- **Deployment**: Single binary with configuration files

### Future Roadmap

- **Modular Rewrite**: Component-based architecture
- **Plugin System**: Extensible plugin architecture
- **API Interface**: RESTful API for integration
- **Web Interface**: Browser-based configuration and management

### Technical Debt

- **Shell Script Limitations**: Considering rewrite in Go/Rust
- **Error Handling**: Improving error recovery mechanisms
- **Testing**: Expanding automated test coverage

## 🛡️ Security Best Practices

### Development Security

- **Code Review**: Security-focused code review process
- **Static Analysis**: Automated security scanning
- **Dependency Management**: Regular security updates

### Operational Security

- **Regular Updates**: Keep dependencies current
- **Security Monitoring**: Continuous security monitoring
- **Incident Response**: Security incident response procedures

### User Security

- **Secure Defaults**: Secure default configuration
- **User Education**: Security best practices documentation
- **Privacy Controls**: User-configurable privacy settings

This architecture and security design ensures that aicommit provides a secure, reliable, and maintainable solution for AI-powered commit message generation while protecting user data and maintaining system integrity.
