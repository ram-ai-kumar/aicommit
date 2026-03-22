# AI Commit Test Suite

Comprehensive test coverage for AI-powered commit message generation, organized for business and technical stakeholders.

## Test Organization

```
features/
├── core-workflows/         # How the system works
├── business-features/      # Business value and compliance
├── quality-assurance/      # Security and reliability
├── step_definitions/       # Test implementation
└── support/                # Test configuration
```

## Test Categories

### 🚀 Core Workflows (`core-workflows/`)
**What it tests**: Basic functionality, end-to-end processes, and operational validation
- **Basic Operations**: System startup, configuration, help system
- **Commit Generation**: AI-powered message creation and formatting
- **Error Handling**: Graceful failure management and user guidance
- **Model Management**: AI model validation and fallback procedures

### 💼 Business Features (`business-features/`)
**What it tests**: Business value, regulatory compliance, and risk management
- **Business Value**: ROI demonstration and strategic alignment
- **Risk Management**: Risk assessment, mitigation, and monitoring
- **Regulatory Compliance**: GDPR, SOC 2, ISO 27001, industry standards
- **Governance**: Board-level reporting and stakeholder value

### 🔒 Quality Assurance (`quality-assurance/`)
**What it tests**: Security, reliability, and trustworthiness
- **Data Protection**: Sensitive data handling and privacy controls
- **Trust & Safety**: Zero Trust principles and threat protection
- **Security Testing**: Vulnerability assessment and penetration testing
- **System Reliability**: Performance, stability, and resilience

## Running Tests

### Prerequisites
- Ruby with Cucumber gem installed
- Bash shell environment
- Git repository for testing
- Optional: Ollama service for integration tests

### Installation
```bash
# Install Cucumber and dependencies
gem install cucumber

# Navigate to project root
cd /Users/ram/Work/code/dev-stack/aicommit

# Run all tests
cucumber

# Run specific category
cucumber features/functional/
cucumber features/security/
cucumber features/compliance/
cucumber features/risk_management/
cucumber features/governance/

# Run specific feature
cucumber features/functional/smoke_tests.feature

# Run with specific tags
cucumber --tag @smoke
cucumber --tag @security
cucumber --tag @compliance
```

### Test Configuration
Tests can be configured via environment variables:

```bash
# Set test environment
export TEST_ENV=ci  # or development, staging

# Configure mock services
export MOCK_OLLAMA=true
export TEST_TIMEOUT=30

# Set log level
export CUCUMBER_LOG_LEVEL=debug
```

## Test Scenarios Overview

### Basic Functionality (8 scenarios)
- Application loading and function availability
- Default configuration validation
- Help system functionality
- Temporary directory management
- Ollama model interaction
- Library function availability

### Error Handling (15 scenarios)
- Invalid command line options
- Missing staged changes
- Unsupported backends
- Missing context files
- Service failures
- Permission issues

### Boundary Conditions (25 scenarios)
- Empty input handling
- Large file processing
- Special characters in filenames
- Unicode content
- Deep directory structures
- Concurrent access

### System Resilience (25 scenarios)
- Git command failures
- Service crashes
- Network issues
- Resource exhaustion
- Process interruption
- Filesystem errors

### Data Protection (25 scenarios)
- Permission validation
- Sensitive data exclusion
- Input sanitization
- Path traversal prevention
- Command injection protection
- Data leakage prevention

### Trust and Safety (20 scenarios)
- Component verification
- Local-only processing
- Least privilege enforcement
- Micro-segmentation
- Continuous validation
- Governance enforcement

### Regulatory Compliance (25 scenarios)
- GDPR data protection
- SOC 2 controls
- ISO 27001 ISMS
- Industry regulations
- Audit requirements
- Documentation standards

### Risk Assessment (25 scenarios)
- Risk assessment
- Mitigation strategies
- Monitoring and reporting
- Incident management
- Emerging risks
- Governance oversight

### Business Value (20 scenarios)
- Strategic alignment
- Business value
- Risk posture
- Investment justification
- Stakeholder value
- Board reporting

## Test Data and Mocking

### Mock Services
- **Ollama Service**: Simulated LLM responses for testing
- **Git Repository**: Isolated test repositories for each scenario
- **File System**: Temporary directories with controlled permissions

### Test Fixtures
- Sample code files (JavaScript, Python, etc.)
- Configuration files (.env, .json, .yaml)
- Sensitive data examples (sanitized for testing)
- Large file samples for performance testing

## Continuous Integration

### GitHub Actions Integration
```yaml
name: Cucumber Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0
      - name: Install dependencies
        run: |
          gem install cucumber
      - name: Run tests
        run: |
          cucumber --format junit --out test-results/
```

### Test Reporting
- JUnit XML format for CI integration
- HTML reports for local development
- JSON output for programmatic consumption
- Coverage metrics and trend analysis

## Maintenance

### Adding New Tests
1. Identify appropriate category (functional, security, compliance, etc.)
2. Create feature file in relevant directory
3. Implement step definitions in `step_definitions/`
4. Add tags for proper categorization
5. Update documentation

### Test Updates
- Review and update scenarios quarterly
- Align with changing security requirements
- Incorporate new regulatory requirements
- Update mock services as needed

### Best Practices
- Keep scenarios focused and independent
- Use descriptive scenario names
- Implement proper cleanup in After hooks
- Use tags for test categorization
- Maintain comprehensive documentation

## Troubleshooting

### Common Issues
- **Permission Denied**: Ensure test directories have proper permissions
- **Git Repository Issues**: Check git configuration and repository state
- **Service Unavailable**: Verify mock service configuration
- **Timeout Errors**: Adjust timeout values for slow systems

### Debug Mode
```bash
# Enable debug logging
cucumber --format pretty --verbose

# Run specific scenario with debug
cucumber features/functional/smoke_tests.feature:10 --format pretty
```

### Test Isolation
Each scenario runs in an isolated environment with:
- Temporary git repository
- Clean working directory
- Fresh environment variables
- Isolated temporary files

This comprehensive test suite ensures aicommit meets the highest standards for functionality, security, compliance, and governance across all organizational levels.
