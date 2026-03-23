# TODO - Scheduled, Pending & Planned Features

This document consolidates all scheduled, pending, and planned features from across the project documentation.

---

## 🚨 Critical Priority (Security & Compliance)

### Enhanced Security Testing Framework (Cucumber-Ruby BDD)

**Status**: Pending
**Area**: Testing, security documentation, stakeholder communication
**Description**: Implement Cucumber-Ruby BDD framework for security testing with non-technical stakeholder readability
**Key Changes**:

- Universal Gherkin features for security scenarios
- Expand from 8 to 11 test categories (add zta-validation, privacy-first, audit-ready)
- Living security documentation with automated compliance evidence
  **Success Metrics**: Non-technical stakeholder communication, automated compliance evidence

### BDD Implementation Stages (All 6 Stages)

**Status**: Stage 1 Completed ✅, Stages 2-6 Pending
**Area**: Comprehensive testing coverage, business alignment
**Description**: Complete implementation of all 6 BDD stages for full test coverage
**Key Changes**:

- **Stage 2**: Advanced error handling, performance, configuration management
- **Stage 3**: Business logic validation, advanced workflows, AI features
- **Stage 4**: Security framework testing, data protection, regulatory compliance
- **Stage 5**: Business value measurement, governance, organizational impact
- **Stage 6**: Ecosystem integration, advanced AI, enterprise features
  **Success Metrics**: Complete business-oriented test coverage, stakeholder alignment

### Fix Security Scan False Positives

**Status**: Pending
**Area**: Security validation, CI/CD compliance
**Description**: Implement context-aware secret detection to eliminate 100% false positives from current security scan
**Key Changes**:

- Enhanced pattern matching for actual secrets vs. legitimate code
- Context-aware validation (skip comments, patterns, test fixtures)
- Multi-layer detection (pattern-based, entropy-based, context-aware)
  **Success Metrics**: 0% false positive rate, 100% secret detection accuracy

### Zero Trust Architecture Compliance Implementation

**Status**: Pending
**Area**: Security architecture, regulatory compliance
**Description**: Implement comprehensive ZTA validation framework with automated verification
**Key Changes**:

- "Never Trust, Always Verify" backend validation
- "Assume Breach" controls with data exfiltration prevention
- "Least Privilege" implementation with minimal permissions
- "Micro-segmentation" validation with isolated temp directories
- "No Implicit Trust" controls with verification before use
  **Success Metrics**: Automated ZTA validation, audit-ready documentation

### Enhanced Security Testing Framework (Cucumber-Ruby BDD)

**Status**: Pending
**Area**: Testing, security documentation, stakeholder communication
**Description**: Implement Cucumber-Ruby BDD framework for security testing with non-technical stakeholder readability
**Key Changes**:

- Universal Gherkin features for security scenarios
- Expand from 8 to 11 test categories (add zta-validation, privacy-first, audit-ready)
- Living security documentation with automated compliance evidence
  **Success Metrics**: Non-technical stakeholder communication, automated compliance evidence

### Regulatory Compliance Automation

**Status**: Pending
**Area**: Compliance, audit readiness, governance
**Description**: Implement automated compliance validation and reporting for SOC 2, GDPR, HIPAA, NIST 800-53
**Key Changes**:

- SOC 2 Change Management automation
- GDPR Data Protection by Design validation
- HIPAA Technical Safeguards verification
- NIST 800-53 Configuration Change Control
- Automated compliance reporting script
  **Success Metrics**: Continuous compliance monitoring, always audit-ready

### Model Selection Preference (Configured/Default Only)

**Status**: Completed ✅
**Area**: Model management, user control, predictable behavior
**Description**: Strict model preference that only uses configured or default models
**Key Changes**:

- Remove loaded model priority (no fallback to randomly loaded models)
- Restrict fallback to known default models only
- Enhanced model validation with clear error messages
  **Success Metrics**: 100% configuration respect, predictable model behavior

---

## 🔥 High Priority

### Publish-Ready Installer

**Status**: Pending
**Area**: Distribution readiness
**Description**: Replace hardcoded `<user>` placeholder with actual GitHub username/org in installer
**Key Changes**:

- Replace `<user>` with actual GitHub username
- Add environment variable override for organizations
- Enable one-liner installation without manual edits
  **Success Metrics**: Out-of-the-box installability for external users

### Guided Ollama Onboarding in Installer

**Status**: Pending
**Area**: Developer experience, zero-friction adoption
**Description**: Enhanced installer with guided, non-invasive onboarding flow
**Key Changes**:

- Ollama detection with helpful install instructions (no auto-install)
- Model discovery and user selection for available models
- Recommendations for lightweight capable models when none exist
- Automatic config writing to `~/.aicommitrc`
  **Security Constraint**: Never auto-download models or install software - preserve Zero Trust
  **Success Metrics**: Zero-config first-run experience, guided model setup

### Global Installer Enhancement

**Status**: Pending
**Area**: Distribution, first-run experience
**Description**: Automatic shell profile integration for global installation
**Key Changes**:

- Detect Zsh/Bash automatically
- Add source line to `.zshrc` or `.bashrc`
- Zero-config global setup
  **Success Metrics**: Automatic shell integration, no manual steps required

---

## 📈 Medium Priority

### Enhanced Model Discovery

**Status**: Pending
**Area**: User experience, model management
**Description**: Add model discovery and recommendation features
**Key Changes**:

- Automatic detection of available models
- Size and capability recommendations
- Memory requirement estimates
- Model compatibility checks
  **Success Metrics**: Informed model selection, reduced trial-and-error

### Configuration Validation

**Status**: Pending
**Area**: User experience, error prevention
**Description**: Add startup configuration validation
**Key Changes**:

- Model availability checks
- Backend connectivity validation
- Configuration file syntax checking
- Early error reporting with actionable suggestions
  **Success Metrics**: Early error detection, clear actionable feedback

---

## 🔧 Low Priority

### Additional Backend Support

**Status**: Pending
**Area**: Extensibility, user choice
**Description**: Add support for additional local LLM backends
**Key Changes**:

- llama.cpp direct integration
- LocalAI API compatibility
- Custom backend interface
  **Success Metrics**: Multiple backend choices, extended ecosystem support

### Performance Optimizations

**Status**: Pending
**Area**: Performance, user experience
**Description**: Optimize for better performance
**Key Changes**:

- Parallel processing where possible
- Caching of model availability
- Faster diff processing for large repositories
- Progress indicators for long operations
  **Success Metrics**: Optimized operations, better user feedback

---

## 📊 Business-Oriented Feature Categories

### 🎯 Stakeholder Experience (5 features - 26%)

**Focus**: User interactions, developer experience, and end-user value
**Features**:

- user-onboarding.feature - New developer onboarding and setup experience
- developer-workflow.feature - Enhanced developer productivity and workflow integration
- commit-standards.feature - Conventional commit standards and best practices
- commit-quality.feature - Commit message quality validation and improvement
- user-feedback.feature - Error handling and user communication

### 🔧 Technology Stack (5 features - 26%)

**Focus**: Technical implementation, integrations, and system architecture
**Features**:

- git-integration.feature - Git workflow integration and automation
- core-architecture.feature - System architecture and library functions
- ai-resilience.feature - AI backend connectivity and fallback strategies
- system-performance.feature - Performance, scalability, and resilience
- workflow-automation.feature - End-to-end workflow automation

### 🔒 Security & Compliance (4 features - 21%)

**Focus**: Data protection, regulatory requirements, and security measures
**Features**:

- privacy-protection.feature - Data privacy and sensitive information protection
- security-framework.feature - Zero Trust Architecture implementation
- content-safety.feature - Content safety and threat detection
- compliance-standards.feature - Regulatory compliance (GDPR, SOX, etc.)

### ⚠️ Risk Management (3 features - 16%)

**Focus**: Risk identification, assessment, and mitigation
**Features**:

- edge-case-testing.feature - Boundary conditions and edge case handling
- business-risk.feature - Comprehensive business risk assessment
- failure-recovery.feature - Error handling and system recovery

### 📊 Business Operations (2 features - 11%)

**Focus**: Business value, operational efficiency, and governance
**Features**:

- deployment-automation.feature - Installation, deployment, and setup automation
- value-delivery.feature - Business value measurement and ROI tracking

---

## ✅ Completed Items

The following items have been implemented and are no longer pending:

- ✅ **Model Fallback Enhancement** - Intelligent model switching with memory-aware error handling
- ✅ **Security Hardening** - Model name sanitization and command injection prevention
- ✅ **Comprehensive Testing** - 87 test cases covering all functionality
- ✅ **Backend Abstraction** - Clean separation between LLM backends
- ✅ **Documentation Organization** - Structured docs with clear navigation
- ✅ **Model Selection Preference** - Strict configuration respect for configured/default models only
- ✅ **BDD Feature Reorganization** - 19 features organized into 5 business-oriented categories

---

## 📅 Timeline Summary

### Immediate (Next 2-4 weeks)

- Critical security fixes (false positives, ZTA compliance)
- Publish-ready installer
- Guided Ollama onboarding

### Short-term (1-3 months)

- Enhanced security testing framework
- Regulatory compliance automation
- Global installer enhancement
- Stage 2 BDD implementation

### Medium-term (3-6 months)

- Enhanced model discovery and configuration validation
- Stages 3-4 BDD implementation
- Additional backend support

### Long-term (6+ months)

- Performance optimizations
- Stages 5-6 BDD implementation
- Enterprise features and advanced integrations

---

**Last Updated**: 2026-03-23
**Maintainers**: AI Commit Development Team
**Next Review**: 2026-04-06
