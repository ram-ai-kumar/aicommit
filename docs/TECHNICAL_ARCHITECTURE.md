# Technical Architecture

> System design, component architecture, and technical implementation details for AI Commit. For security architecture details, see [Security Architecture](SECURITY_ARCHITECTURE.md).

## 🏗️ System Overview

This document covers the complete technical architecture, system design, and implementation details for the AI Commit project, including component interactions, data flows, and technical specifications.

## 🏛️ High-Level Architecture

### Directory Structure

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

## 🔧 Core Components

### 1. AI Commit Script (`aicommit.sh`)

**Purpose**: Main entry point and orchestration script  
**Language**: Bash shell script  
**Responsibilities**:
- Environment setup and configuration loading
- Git integration and diff analysis
- AI backend communication
- Output formatting and user interaction

**Key Functions**:
```bash
# Main execution flow
main() {
    load_configuration
    validate_environment
    analyze_git_changes
    generate_commit_message
    format_output
}

# Configuration management
load_configuration() {
    source ~/.aicommitrc 2>/dev/null || true
    source config/defaults.sh
}
```

### 2. Library Functions (`lib/`)

#### core.sh
- **Purpose**: Core business logic and commit message generation
- **Functions**:
  - `generate_prompt()` - Build AI prompt with context
  - `process_response()` - Process AI response
  - `validate_message()` - Validate commit message format

#### backends.sh
- **Purpose**: AI backend integration (Ollama, OpenAI, etc.)
- **Functions**:
  - `detect_backend()` - Detect available AI backends
  - `call_ollama()` - Local LLM inference
  - `call_openai()` - Cloud API integration
  - `fallback_backend()` - Backend fallback logic

#### context-analyzer.sh
- **Purpose**: Git diff analysis and context building
- **Functions**:
  - `analyze_diff()` - Analyze git diff output
  - `detect_project_type()` - Identify project framework
  - `build_context()` - Build AI context
  - `filter_sensitive_data()` - Remove sensitive information

#### output-formatter.sh
- **Purpose**: Result formatting and display
- **Functions**:
  - `format_commit_message()` - Format conventional commits
  - `display_preview()` - Show commit message preview
  - `colorize_output()` - Add color formatting

### 3. Configuration Management (`config/`)

#### defaults.sh
- **Purpose**: Default configuration values
- **Settings**:
  - Default AI model preferences
  - Output formatting options
  - Security and privacy settings

#### User Configuration
- **Location**: `~/.aicommitrc`
- **Format**: Key-value pairs
- **Override**: Environment variables take precedence

#### Configuration Hierarchy
1. **Environment Variables** (highest priority)
2. **User Config** (`~/.aicommitrc`)
3. **Default Config** (`config/defaults.sh`)

### 4. Templates (`templates/`)

#### prompt.txt
- **Purpose**: AI model prompt template
- **Variables**:
  - `{{CONTEXT}}` - Git diff context
  - `{{PROJECT_TYPE}}` - Project framework
  - `{{CHANGE_TYPE}}` - Type of changes
  - `{{RULES}}` - Commit message rules

#### Custom Templates
- User-defined prompt templates
- Project-specific templates
- Language-specific templates

## 🔄 Data Flow Architecture

### Processing Pipeline

```
Git Repository → Diff Analysis → Context Building → AI Backend → Message Generation → Output Formatting
```

### Detailed Flow

1. **Git Integration**
   - Analyze staged changes and generate diff
   - Extract file types and change patterns
   - Identify project framework and conventions

2. **Context Analysis**
   - Build context from file types, changes, and history
   - Filter sensitive data and credentials
   - Create project-specific context

3. **AI Communication**
   - Send context to AI backend for message generation
   - Handle backend selection and fallback
   - Manage error handling and retries

4. **Result Processing**
   - Format and display generated commit message
   - Validate conventional commit format
   - Provide user preview and confirmation

### Data Structures

#### Git Diff Processing
```bash
# Diff analysis output structure
declare -A diff_analysis
diff_analysis[files]="file1.js file2.py"
diff_analysis[additions]="150"
diff_analysis[deletions]="45"
diff_analysis[file_types]="js py"
diff_analysis[project_type]="javascript"
```

#### AI Context Building
```bash
# Context structure for AI prompt
declare -A ai_context
ai_context[project_name]="my-project"
ai_context[framework]="react"
ai_context[changes]="feature: user authentication"
ai_context[files_modified]="auth.js auth.test.js"
ai_context[sensitive_files]=".env config.json"
```

## 🤖 Backend Architecture

### Supported AI Backends

#### Ollama (Primary)
- **Type**: Local LLM inference
- **Models**: qwen2.5-coder, llama3.2, etc.
- **Communication**: HTTP API on localhost:11434
- **Advantages**: Privacy, offline operation, no API costs

#### OpenAI (Fallback)
- **Type**: Cloud API integration
- **Models**: GPT-3.5-turbo, GPT-4
- **Communication**: HTTPS API
- **Authentication**: API key required

#### Custom Backends
- **Type**: Extensible backend system
- **Interface**: Standardized API contract
- **Examples**: LocalAI, llama.cpp, custom models

### Backend Selection Logic

```bash
select_backend() {
    local preferred_model="$1"
    
    # 1. Check configured backend preference
    if [[ -n "$AI_BACKEND" ]]; then
        if verify_backend "$AI_BACKEND"; then
            echo "$AI_BACKEND"
            return 0
        fi
    fi
    
    # 2. Try Ollama (local preference)
    if check_ollama_available; then
        echo "ollama"
        return 0
    fi
    
    # 3. Try configured fallback backends
    for backend in "${FALLBACK_BACKENDS[@]}"; do
        if verify_backend "$backend"; then
            echo "$backend"
            return 0
        fi
    done
    
    # 4. No backend available
    return 1
}
```

### Model Management

#### Model Detection
- Automatic detection of available models
- Model capability assessment
- Size and performance optimization

#### Model Selection
- User preference configuration
- Automatic fallback logic
- Performance-based optimization

#### Model Validation
- Model availability checking
- Load testing and validation
- Error handling and recovery

## 🛠️ Technical Implementation

### Error Handling Strategy

#### Graceful Degradation
- **Backend Failures**: Fallback to alternative backends
- **Network Issues**: Local processing when possible
- **Invalid Input**: Helpful error messages and suggestions
- **Resource Limits**: Configurable timeouts and limits

#### Recovery Mechanisms
- **Automatic Retry**: Configurable retry logic for transient failures
- **State Recovery**: Resume interrupted operations
- **Cleanup Procedures**: Ensure system cleanup on errors
- **Error Reporting**: User-friendly error messages

### Performance Considerations

#### Optimization Strategies
- **Caching**: Cache AI responses for similar changes
- **Parallel Processing**: Parallel file analysis when possible
- **Resource Management**: Efficient memory and CPU usage
- **Batch Processing**: Process multiple files together

#### Scalability Design
- **Modular Architecture**: Easy to extend with new features
- **Configuration Flexibility**: Adaptable to different environments
- **Backend Abstraction**: Support for multiple AI providers
- **Plugin System**: Extensible plugin architecture

### Monitoring and Observability

#### Logging Strategy
- **Structured Logging**: Consistent log format for analysis
- **Security Events**: Log security-relevant events
- **Performance Metrics**: Track response times and success rates
- **Debug Information**: Detailed debugging capabilities

#### Debugging Support
- **Verbose Mode**: Detailed debugging information
- **Dry Run**: Preview changes without committing
- **Configuration Validation**: Verify setup before processing
- **Health Checks**: System health monitoring

## 🚀 Deployment Architecture

### Installation Methods

#### System Installation
- **Global Install**: System-wide availability
- **Path Integration**: Automatic PATH configuration
- **Shell Integration**: Zsh/Bash completion setup

#### User Installation
- **Per-User**: Individual user installation
- **Home Directory**: Installation in user home
- **No Sudo Required**: User-level permissions only

#### Portable Operation
- **Standalone**: Operation without installation
- **Self-Contained**: All dependencies included
- **Cross-Platform**: Linux, macOS, Windows support

### Configuration Management

#### Environment Variables
- **AI_MODEL**: Preferred AI model
- **AI_BACKEND**: AI backend selection
- **AICOMMIT_DEBUG**: Enable debug mode
- **AICOMMIT_CONFIG**: Custom config file path

#### Configuration Files
- **~/.aicommitrc**: User configuration
- **config/defaults.sh**: Default settings
- **Project Config**: Project-specific settings

#### Command Line Options
- **--model**: Override AI model
- **--backend**: Override AI backend
- **--dry-run**: Preview without committing
- **--verbose**: Enable verbose output

## 🔌 Integration Points

### Git Integration

#### Git Hooks
- **Pre-commit**: Automatic commit message generation
- **Prepare-commit-msg**: Message validation
- **Post-commit**: Cleanup and logging

#### Workflow Integration
- **CI/CD Pipeline**: Automated commit generation
- **Build System**: Integration with build tools
- **IDE Integration**: Editor plugin support

#### Version Control
- **Git Compatibility**: Full Git workflow support
- **Branch Support**: Multi-branch development
- **Merge Handling**: Merge commit message generation

### AI Backend Integration

#### Local Backends
- **Ollama**: Native local LLM support
- **llama.cpp**: Direct model integration
- **LocalAI**: Local API server support

#### Cloud Backends
- **OpenAI**: GPT model integration
- **Anthropic**: Claude model support
- **Custom APIs**: Extensible API integration

#### Backend Abstraction
- **Standard Interface**: Consistent API across backends
- **Configuration**: Backend-specific configuration
- **Fallback Logic**: Automatic backend switching

## 📊 Architecture Evolution

### Current State (v1.x)

- **Architecture**: Monolithic shell script with modular libraries
- **Language**: Bash shell script
- **Deployment**: Single binary with configuration files
- **Dependencies**: Minimal external dependencies

### Future Roadmap

#### v2.0 - Modular Rewrite
- **Language**: Go or Rust rewrite
- **Architecture**: Component-based microservices
- **API**: RESTful API interface
- **Plugin System**: Extensible plugin architecture

#### v2.5 - Enhanced Features
- **Web Interface**: Browser-based management
- **Team Features**: Multi-user support
- **Analytics**: Usage analytics and insights
- **Enterprise**: SSO and enterprise features

#### v3.0 - Cloud Native
- **Container Support**: Docker/Kubernetes deployment
- **Microservices**: Distributed architecture
- **API Gateway**: Centralized API management
- **Monitoring**: Advanced observability

### Technical Debt

#### Current Limitations
- **Shell Script Limitations**: Error handling, performance
- **Single-threaded**: No parallel processing
- **Limited Testing**: Manual testing process
- **Configuration**: Basic configuration management

#### Improvement Areas
- **Error Handling**: Improve error recovery mechanisms
- **Performance**: Optimize for large repositories
- **Testing**: Expand automated test coverage
- **Documentation**: Improve technical documentation

## 🔧 Development Guidelines

### Code Standards

#### Shell Script Best Practices
- **Error Handling**: Comprehensive error checking
- **Variable Handling**: Proper variable quoting
- **Function Organization**: Modular function design
- **Documentation**: Inline code documentation

#### Security Considerations
- **Input Validation**: Validate all user inputs
- **Path Security**: Secure file path handling
- **Permission Management**: Proper permission settings
- **Data Protection**: Sensitive data handling

#### Performance Optimization
- **Efficient Algorithms**: Optimize for performance
- **Resource Management**: Memory and CPU optimization
- **Caching**: Implement appropriate caching
- **Parallel Processing**: Use parallelization where possible

### Testing Strategy

#### Unit Testing
- **Function Testing**: Individual function testing
- **Integration Testing**: Component interaction testing
- **Mock Testing**: Backend mocking for testing
- **Edge Cases**: Boundary condition testing

#### Integration Testing
- **Backend Testing**: AI backend integration
- **Git Testing**: Git workflow testing
- **Configuration Testing**: Configuration management testing
- **End-to-End**: Complete workflow testing

#### Performance Testing
- **Load Testing**: Large repository handling
- **Stress Testing**: Resource limit testing
- **Timing Testing**: Performance measurement
- **Scalability Testing**: Scalability assessment

---

## 📞 Technical Resources

### Development Documentation

- [Security Architecture](SECURITY_ARCHITECTURE.md) - Security design and implementation
- [Compliance Framework](COMPLIANCE_FRAMEWORK.md) - Compliance requirements and validation
- [Risk Governance](RISK_GOVERNANCE.md) - Risk management and mitigation
- [Implementation Roadmap](IMPLEMENTATION_ROADMAP.md) - Development roadmap and planning

### Development Resources

- **Source Code**: Main project repository
- **Issue Tracking**: Bug reports and feature requests
- **Development Wiki**: Development guidelines and best practices
- **API Documentation**: Technical API reference

### Support Resources

- **Technical Support**: tech-support@organization.com
- **Development Questions**: dev-questions@organization.com
- **Bug Reports**: bug-reports@organization.com
- **Feature Requests**: feature-requests@organization.com

---

**Document Version**: 1.0  
**Technical Classification**: Internal Technical Documentation  
**Last Updated**: 2026-03-23  
**Next Review**: 2026-04-23  
**Technical Owner**: CTO  
**Implementation Team**: Engineering
