# Security by Design: AI Commit (`aicommit`)

This document outlines the core security architecture, threat models, and design principles underpinning the **AI Commit** project.

`aicommit` was built from the ground up with the premise that **source code is sensitive intellectual property**. Any tooling that processes source code must be subjected to rigorous security and privacy constraints to prevent data exfiltration, credential leaks, and supply chain attacks.

## 1. Zero Trust Architecture

AI Commit implements a Zero Trust philosophy, removing any implicit trust in third-party services, external networks, or even local temporary states.

- **Never trust, always verify:** External dependencies (like the LLM runtime) are validated before every invocation. The presence and health of the active backend (Ollama, llama.cpp, LocalAI) are checked locally.
- **Assume breach:** By architecting the system so that source code **never** leaves the local device, there is no outbound channel or network request to intercept. MITM (Man-in-the-Middle) attacks are structurally impossible for the inference pipeline.
- **Least Privilege:** The application strictly operates with read-only access to `git diff` outputs. It requires no elevated permissions, `sudo` access, or API keys.
- **Micro-segmentation:** Any temporary files generated during the diff processing and prompting stages are strictly scoped on a per-repository basis within isolated directories. They are cleaned up ephemerally.

## 2. Core Security & Privacy Principles

### 100% Local Execution

The primary attack surface of traditional AI coding assistants is the transmission of proprietary source code to cloud APIs. AI Commit fundamentally neutralizes this risk by running all LLM inference locally. There are **zero network calls** to external AI providers (such as OpenAI, Anthropic, or GitHub Copilot).

### Secret & Credential Filtering

Even within a local environment, care is taken to not process sensitive information unnecessarily. AI Commit incorporates intelligent filtering that specifically excludes files likely to contain secrets (`.env` files, credentials, keys) from the AI's context window.

### Ephemeral State Management

AI Commit relies on temporary files to pass context to the LLM. These files are:

1. Created with strict permissions.
2. Kept localized and ephemeral.
3. Automatically destroyed upon successful completion or interruption of the `aicommit` process.
4. The system includes an uninstaller (`uninstall.sh`) that guarantees no orphaned configuration files or hidden services are left behind.

## 3. Threat Model & Mitigations

| Threat                                            | Description                                                                        | Mitigation Strategy                                                                                                                                       |
| :------------------------------------------------ | :--------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Data Exfiltration**                             | Accidental or malicious upload of proprietary source code to external servers.     | Complete reliance on local LLM runtimes. The architecture contains no logic to communicate with remote cloud providers.                                   |
| **Credential Leakage via AI Context**             | Passwords or API keys in staging area being processed or memorized by a model.     | Proactive omission of environment and configuration files from the diff context passed to the local LLM.                                                  |
| **Vendor Lock-in & Phishing via API**             | Third-party services requiring API tokens which could be compromised or abused.    | No API keys needed. The model uses local binaries and local ports.                                                                                        |
| **Denial of Service (DoS) via Hanging Processes** | Large diffs or slow models causing the developer environment to hang indefinitely. | Implementation of rigid circuit breakers: configurable timeouts for Git (30s), LLM inference, file system operations (10s), and network validation (15s). |
| **Telemetry & Tracking Abuse**                    | Unwanted data collection regarding developer habits and project structures.        | Absolute zero telemetry, tracking, or "phone-home" capabilities are built into the tool.                                                                  |

## 4. Compliance and Governance

AI Commit enforces organizational standards by generating precise, machine-parseable, and deterministic **Conventional Commits**. This is not merely a convenience, but a rigorous governance control enabling compliance with multiple industry standards:

- **SOC 2 (CC8.1 - Change Management):** Enforces structured, typed commit messages org-wide, ensuring all changes are categorized and recorded systematically.
- **ISO 27001 (A.12.1.2 - Change Management):** Generates standardized and traceable change documentation automatically.
- **GDPR (Art. 25 - Data Protection by Design):** Adheres to data minimization and localization. No personal data or intellectual property ever leaves the device.
- **HIPAA (§ 164.312 - Technical Safeguards):** Assures zero data transmission to external, potentially non-BAA-compliant AI services.

## 5. Audibility and Transparency

- **Open Source Tooling:** The entire logic of `aicommit` is implemented in readable, open-source Bash. There are no obfuscated binaries or black-box components in the control plane.
- **Verified by Tests:** A rigorous BATS (Bash Automated Testing System) suite validates security assumptions with specific **Security Tests**, **Negative Tests**, and **Exception Tests** ensuring that data leaks are prevented and circuit breakers function as designed.
- **Pinning Models:** Because models run locally, organizations can pin specific model versions (e.g., `qwen2.5-coder:latest`), guaranteeing deterministic behavior and preventing upstream vendors from silently modifying the model's behavior or safety guardrails.
