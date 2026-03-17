# Roadmap

Upcoming improvements, organized by priority — high-impact items first, nice-to-have last.

> **Format:** Each item includes the current limitation, the proposed change, and a trade-off assessment.

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
