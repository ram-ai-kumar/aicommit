# Roadmap

Upcoming improvements, organized by priority — high-impact items first, nice-to-have last.

> **Format:** Each item includes the current limitation, the proposed change, and a trade-off assessment.

---

## Critical Priority (Security & Compliance)

---

### 1. Fix Security Scan False Positives

**Area:** Security validation, CI/CD compliance

#### Current State

Security scan `grep -rE "(password|secret|key|token)"` produces 100% false positives by flagging legitimate security code patterns instead of actual hardcoded secrets. This blocks legitimate development and undermines confidence in security scanning.

#### Root Cause Analysis

- **Overly Broad Pattern**: Matches any occurrence of security-related keywords
- **No Context Awareness**: Flags comments, pattern definitions, and test fixtures
- **No Validation Logic**: Doesn't distinguish between code and data

#### Proposed Change

Implement context-aware secret detection:

1. **Enhanced Pattern Matching**

   ```bash
   # Current (false positives):
   grep -rE "(password|secret|key|token)" --include="*.sh" --exclude-dir=test .

   # Improved (targeted):
   grep -rE "(password|secret|key|token)[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]" --include="*.sh" --exclude-dir=test .
   ```

2. **Context-Aware Validation**
   - Skip comments and documentation
   - Skip pattern definitions (like in aicommit security code)
   - Skip test fixtures and mock data
   - Detect actual hardcoded secrets vs. legitimate security code

3. **Multi-Layer Detection**
   - Pattern-based detection (current)
   - Entropy-based detection (new)
   - Context-aware validation (new)

#### Trade-off Assessment

| Dimension            | Before (now)                  | After                                |
| -------------------- | ----------------------------- | ------------------------------------ |
| False Positive Rate  | ❌ 100% (all alerts are false) | ✅ 0% (only actual secrets flagged)   |
| Security Coverage    | ⚠️ Superficial but noisy       | ✅ Comprehensive and accurate         |
| Developer Experience | ❌ Blocks legitimate work      | ✅ Enables secure development         |
| Implementation       | ✅ Simple                      | ⚠️ More sophisticated detection logic |

#### Success Metrics

- **False Positive Rate**: Target 0% (currently 100%)
- **Secret Detection Accuracy**: Target 100%
- **Developer Velocity**: Eliminate security scan blockers
- **CI/CD Reliability**: Consistent security validation

---

### 2. Zero Trust Architecture Compliance Implementation

**Area:** Security architecture, regulatory compliance

#### Current State

ZTA principles are documented but not systematically validated. No automated verification ensures all 5 ZTA principles are properly implemented and tested.

#### Proposed Change

Implement comprehensive ZTA validation framework:

1. **"Never Trust, Always Verify" Enhancement**
   - Backend validation before every operation
   - Input sanitization for all external data
   - Model availability verification
   - Automated validation testing

2. **"Assume Breach" Controls**
   - No data leaves system without validation
   - All temporary files have 700 permissions
   - No persistent storage of sensitive data
   - Data exfiltration prevention verification

3. **"Least Privilege" Implementation**
   - Read-only access to git diff output
   - No elevated permissions required
   - Minimal file system access
   - Permission validation automation

4. **"Micro-segmentation" Validation**
   - Temp directories isolated per repository
   - No cross-process data sharing
   - Scoped temporary file cleanup
   - Isolation verification

5. **"No Implicit Trust" Controls**
   - Backend validation before use
   - Model verification before inference
   - Timeout protections for all operations
   - Trust boundary validation

#### Trade-off Assessment

| Dimension                 | Before (now)     | After                           |
| ------------------------- | ---------------- | ------------------------------- |
| ZTA Validation            | ❌ Manual, ad-hoc | ✅ Automated, comprehensive      |
| Compliance Evidence       | ❌ Limited        | ✅ Audit-ready documentation     |
| Security Assurance        | ⚠️ Assumed        | ✅ Verified and tested           |
| Implementation Complexity | ✅ Simple         | ⚠️ More sophisticated validation |

---

### 3. Enhanced Security Testing Framework (Cucumber-Ruby BDD)

**Area:** Testing, security documentation, stakeholder communication

#### Current State

8 test categories using BATS, but no behavior-driven security scenarios for non-technical stakeholders. Limited ability to communicate security requirements to compliance teams.

#### Proposed Change

Implement Cucumber-Ruby BDD framework for security testing:

1. **Universal Gherkin Features**
   ```gherkin
   Feature: Zero Trust Architecture Implementation
     As a security-conscious organization
     I want aicommit to implement Zero Trust principles
     So that source code never crosses trust boundaries

   Scenario: Never trust, always verify backend
     Given I have aicommit installed
     And I have an unsupported LLM backend configured
     When I attempt to run aicommit
     Then backend validation should fail explicitly
     And no source code should be processed
   ```

2. **Enhanced Test Categories** (expand from 8 to 11)
   - smoke, unit, negative, edge, security, exception, compliance, integration
   - **NEW**: zta-validation, privacy-first, audit-ready

3. **Living Security Documentation**
   - Non-technical stakeholder readability
   - Automated compliance evidence generation
   - Continuous security validation
   - Audit-ready reporting

#### Trade-off Assessment

| Dimension                 | Before (now)     | After                         |
| ------------------------- | ---------------- | ----------------------------- |
| Test Coverage             | ✅ 8 categories   | ✅ 11 categories               |
| Stakeholder Communication | ❌ Technical only | ✅ Non-technical readability   |
| Security Documentation    | ❌ Static         | ✅ Living, automated           |
| Implementation            | ✅ BATS only      | ⚠️ Hybrid BATS + Cucumber-Ruby |

---

### 4. Regulatory Compliance Automation

**Area:** Compliance, audit readiness, governance

#### Current State

Manual compliance verification for SOC 2, GDPR, HIPAA, NIST 800-53. No automated evidence generation or continuous compliance monitoring.

#### Proposed Change

Implement automated compliance validation and reporting:

1. **SOC 2 Change Management**
   - Conventional commit enforcement verification
   - Structured change documentation validation
   - Machine-parseable commit history verification

2. **GDPR Data Protection by Design**
   - No code/personal data leaves device verification
   - Local-only processing validation
   - Data minimization principle verification

3. **HIPAA Technical Safeguards**
   - Zero data transmission to external AI services
   - Access control validation
   - Audit log verification

4. **NIST 800-53 Configuration Change Control**
   - Conventional commits provide structured change records
   - Configuration management validation
   - Change attribution verification

5. **Automated Compliance Reporting**
   ```bash
   # Generate comprehensive compliance report
   ./scripts/generate_compliance_report.sh
   # Outputs: COMPLIANCE_REPORT.md with audit evidence
   ```

#### Trade-off Assessment

| Dimension               | Before (now)         | After                     |
| ----------------------- | -------------------- | ------------------------- |
| Compliance Verification | ❌ Manual, periodic   | ✅ Automated, continuous   |
| Audit Readiness         | ❌ Preparation needed | ✅ Always ready            |
| Evidence Generation     | ❌ Manual collection  | ✅ Automated artifacts     |
| Regulatory Alignment    | ⚠️ Assumed            | ✅ Verified and documented |

---

### 5. Model Selection Preference (Configured/Default Only)

**Area:** Model management, user control, predictable behavior

#### Current State

When configured model fails to load, system falls back to any available model in ollama, including randomly loaded models. This can lead to unpredictable behavior and unexpected model usage.

#### Root Cause Analysis

- **Fallback Logic**: `find_fallback_model()` searches all available models in ollama
- **Loaded Model Priority**: System first tries models already loaded in memory
- **Available Model Priority**: Falls back to any available model if preferred fails
- **User Expectation**: Users expect only their configured model or default to be used

#### Proposed Change

Implement strict model preference that only uses configured or default models:

1. **Remove Loaded Model Priority**
   - Don't search `get_loaded_ollama_models()`
   - Only use explicitly configured models
   - Prevent fallback to randomly loaded models

2. **Restrict Fallback to Default Models**
   - Only fall back to known good default models
   - Remove arbitrary model selection
   - Maintain predictable behavior

3. **Enhanced Model Validation**
   - Better error messages for model failures
   - Clear guidance on model selection
   - Respect user configuration explicitly

#### Implementation Changes

```bash
# Current fallback logic (lines 90-105):
find_fallback_model() {
    local preferred_model="$1"
    local available_models
    available_models=$(get_available_ollama_models)

    # First try to use a model that is already loaded in memory
    local loaded_models
    loaded_models=$(get_loaded_ollama_models)

    if [ -n "$loaded_models" ]; then
        while IFS= read -r model; do
            # ... fallback logic for loaded models
        done <<< "$loaded_models"
    fi

    # Then try commit-specific models
    # ... fallback to any available model
}

# New strict preference logic:
find_fallback_model() {
    local preferred_model="$1"
    local default_models=(
        "qwen2.5-coder:latest"
        "qwen2.5:latest"
        "llama3.2:latest"
        "llama3.1:latest"
        "llama3:latest"
    )

    # Only try the preferred model if it's available
    if ollama list 2>/dev/null | grep -qF "$preferred_model"; then
        if test_model_loadability "$preferred_model"; then
            echo "$preferred_model"
            return 0
        fi
    fi

    # Only try known default models, not arbitrary available models
    for model in "${default_models[@]}"; do
        if ollama list 2>/dev/null | grep -qF "$model" && [ "$model" != "$preferred_model" ]; then
            if test_model_loadability "$model"; then
                echo "$model"
                return 0
            fi
        fi
    done

    return 1  # No suitable model found
}
```

#### Trade-off Assessment

| Dimension            | Before (now)             | After                            |
| -------------------- | ------------------------ | -------------------------------- |
| User Control         | ❌ Unpredictable fallback | ✅ Strict configuration respect   |
| Model Predictability | ❌ Random model usage     | ✅ Only configured/default models |
| Error Handling       | ⚠️ Generic fallback       | ✅ Clear model-specific guidance  |
| Implementation       | ✅ Complex fallback       | ⚠️ Simpler, more restrictive      |

#### Success Metrics

- **Configuration Respect**: 100% adherence to user model preference
- **Predictable Behavior**: No unexpected model selection
- **Clear Error Messages**: Model-specific guidance instead of generic fallback
- **User Trust**: System respects user configuration explicitly

---

## High Priority

---

### 1. Publish-Ready Installer

**Area:** Distribution readiness

#### Current State

The installer hardcodes `<user>` as the GitHub username placeholder. The project cannot be installed via the documented `curl` one-liner without manual edits.

#### Proposed Change

Replace `<user>` with the actual GitHub username/org. Consider adding an environment variable override for organizations hosting forks:

```bash
REPO_URL="${AICOMMIT_REPO:-https://github.com/actual-user/aicommit.git}"
```

#### Trade-off Assessment

| Dimension      | Before (now)                | After                      |
| -------------- | --------------------------- | -------------------------- |
| Installability | ❌ Broken for external users | ✅ Works out of the box     |
| Effort         | —                           | ✅ Trivial find-and-replace |

---

### 2. Guided Ollama Onboarding in Installer

**Area:** Developer experience, zero-friction adoption

#### Current State

The installer checks for `ollama` with `command -v` and exits with a generic error if it's missing. It doesn't help the user install Ollama, doesn't discover already-installed models, and doesn't offer to configure a model. New users face a gap between "installed aicommit" and "ready to use aicommit."

#### Proposed Change

Enhance `install.sh` with a guided, non-invasive onboarding flow:

1. **Ollama not found** — show install instructions (link to <https://ollama.ai/download>) and exit gracefully. Never auto-install.
2. **Ollama found, models exist** — list available models, ask the user which one to use, write the choice to `~/.aicommitrc`.
3. **Ollama found, no models** — show help text recommending the lightest capable model:

   ```bash
   No models found. Pull a model to get started:

     ollama pull qwen2.5-coder:1.5b    (recommended — 1.5B params, lightweight, code-optimized)
     ollama pull qwen2.5-coder:latest   (larger, higher quality)
     ollama pull llama3.2               (general-purpose, 3B params)
   ```

   Then exit. Never auto-download models.

**Key design constraint:** The installer must never make network calls or install software on the user's behalf. All model downloads and Ollama installation are explicit user actions. This preserves the Zero Trust posture — the user controls what enters their environment.

#### Trade-off Assessment

| Dimension            | Before (now)                        | After                                        |
| -------------------- | ----------------------------------- | -------------------------------------------- |
| First-run experience | ❌ Fails with generic error          | ✅ Guided, actionable next steps              |
| Model discovery      | ❌ None — user must manually check   | ✅ Shows available models, lets user pick     |
| Config automation    | ❌ User must hand-edit `.aicommitrc` | ✅ Writes `AI_MODEL` to config automatically  |
| Security posture     | ✅ No auto-downloads                 | ✅ Preserved — all actions are user-initiated |
| Installer complexity | ✅ Minimal                           | ⚠️ More conditional logic to maintain         |

---

### 3. Global Installer Enhancement

**Area:** Distribution, first-run experience

#### Current State

Basic installer exists but doesn't automatically integrate with shell profiles.

#### Proposed Change

A script that detects Zsh/Bash and automatically adds the `source` line to `.zshrc` or `.bashrc`.

#### Trade-off Assessment

| Dimension            | Before (now)         | After                  |
| -------------------- | -------------------- | ---------------------- |
| First-run experience | ❌ Manual integration | ✅ Automatic setup      |
| User effort          | ❌ Manual steps       | ✅ Zero-config install  |
| Complexity           | ✅ Simple             | ⚠️ More installer logic |

---

## Medium Priority

---

### 4. Enhanced Model Discovery

**Area:** User experience, model management

#### Current State

Users must manually check available models and understand compatibility.

#### Proposed Change

Add model discovery and recommendation features:

- Automatic detection of available models
- Size and capability recommendations
- Memory requirement estimates
- Model compatibility checks

#### Trade-off Assessment

| Dimension       | Before (now)      | After                        |
| --------------- | ----------------- | ---------------------------- |
| User guidance   | ❌ Manual research | ✅ Automated recommendations  |
| Model selection | ❌ Trial and error | ✅ Informed choices           |
| Implementation  | —                 | ⚠️ Additional discovery logic |

---

### 5. Configuration Validation

**Area:** User experience, error prevention

#### Current State

Configuration errors are discovered only during runtime.

#### Proposed Change

Add configuration validation that runs on startup:

- Model availability checks
- Backend connectivity validation
- Configuration file syntax checking
- Early error reporting with actionable suggestions

#### Trade-off Assessment

| Dimension       | Before (now)             | After                         |
| --------------- | ------------------------ | ----------------------------- |
| Error detection | ❌ Runtime failures       | ✅ Early validation            |
| User experience | ❌ Cryptic error messages | ✅ Clear, actionable feedback  |
| Implementation  | —                        | ⚠️ Additional validation layer |

---

## Low Priority

---

### 6. Additional Backend Support

**Area:** Extensibility, user choice

#### Current State

Only Ollama backend is fully supported.

#### Proposed Change

Add support for additional local LLM backends:

- llama.cpp direct integration
- LocalAI API compatibility
- Custom backend interface

#### Trade-off Assessment

| Dimension       | Before (now)     | After                          |
| --------------- | ---------------- | ------------------------------ |
| Backend options | ❌ Ollama only    | ✅ Multiple backend choices     |
| Maintenance     | ✅ Single backend | ⚠️ Multiple backend maintenance |
| Complexity      | ✅ Simple         | ⚠️ More complex abstraction     |

---

### 7. Performance Optimizations

**Area:** Performance, user experience

#### Current State

Basic functionality without performance tuning.

#### Proposed Change

Optimize for better performance:

- Parallel processing where possible
- Caching of model availability
- Faster diff processing for large repositories
- Progress indicators for long operations

#### Trade-off Assessment

| Dimension       | Before (now)        | After                         |
| --------------- | ------------------- | ----------------------------- |
| Speed           | ❌ Basic performance | ✅ Optimized operations        |
| User experience | ❌ Limited feedback  | ✅ Progress indicators         |
| Complexity      | ✅ Simple            | ⚠️ More complex implementation |

---

## Completed Items ✅

The following items have been implemented and are no longer in the roadmap:

- ✅ **Model Fallback Enhancement** - Intelligent model switching with memory-aware error handling
- ✅ **Security Hardening** - Model name sanitization and command injection prevention
- ✅ **Comprehensive Testing** - 87 test cases covering all functionality
- ✅ **Backend Abstraction** - Clean separation between LLM backends
- ✅ **Documentation Organization** - Structured docs with clear navigation

---

**Last Updated**: 2026-03-18
**Maintainers**: AI Commit Development Team
