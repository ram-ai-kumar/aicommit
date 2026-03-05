# AI Commit (`aicommit`)

**Zero-Trust, Privacy-First, Compliance-Ready AI-Driven Git Tooling**

Locally-executed, regulatory-aligned developer tooling that generates [Conventional Commits](https://www.conventionalcommits.org/) messages using an on-device LLM via [Ollama](https://ollama.ai/). Source code never crosses a trust boundary. No cloud APIs. No API keys. No data exfiltration surface. Full alignment with your organization's security, privacy, and governance posture.

---

## Why AI Commit?

Developer AI tools that send source code to cloud providers introduce risk at every level — data exposure, vendor lock-in, compliance burden, unpredictable costs. **AI Commit eliminates all of it** by running the entire AI pipeline locally.

| Concern | AI Commit |
|---------|----------|
| Source code sent to third parties | **Never** — all inference is local |
| API keys & credential management | **None required** |
| Telemetry / analytics / phone-home | **Zero** |
| Internet dependency | **Works fully offline** |
| Per-seat or per-token cost | **None** — runs on hardware you own |

---

## Zero Trust Architecture

AI Commit is designed around Zero Trust principles — no implicit trust in external services, every operation validated, data never crosses trust boundaries.

| ZTA Principle | Implementation |
|---------------|----------------|
| **Never trust, always verify** | Validates LLM runtime and model availability before every invocation |
| **Assume breach** | Source code never leaves the device — no outbound channel to intercept |
| **Least privilege** | Read-only access to `git diff` output; no elevated permissions required |
| **Micro-segmentation** | Temp files scoped per-repository in isolated directories |
| **No implicit trust in external services** | Locally-hosted LLM only — zero cloud AI provider dependency |

---

## Security & Privacy

> **Core guarantee:** No source code, diff content, or intellectual property is ever transmitted outside the developer's machine.

- **No network calls to AI services** — removes API interception, MITM, and token exfiltration attack surfaces
- **No persistent storage of diffs** — temp files are ephemeral and repo-scoped
- **Open source & fully auditable** — readable bash scripts; no compiled binaries, no obfuscated logic
- **Clean lifecycle** — installer/uninstaller leave no orphaned files, configs, or hidden services
- **No PII exposure via LLM training** — local model, no data upload, impossible for your code to enter any training dataset

---

## Compliance & Governance

Standardized commit messages create a **machine-parseable, auditable change history** — not just a developer convenience, but a governance control.

### Regulatory Alignment

| Framework | Control | How AI Commit Supports |
|-----------|---------|-----------------------|
| **SOC 2** | CC8.1 — Change Management | Structured, typed commit messages enforced org-wide |
| **ISO 27001** | A.12.1.2 — Change Management | Standardized, traceable change documentation |
| **GDPR** | Art. 25 — Data Protection by Design | No code/personal data leaves the device |
| **HIPAA** | § 164.312 — Technical Safeguards | Zero data transmission to external AI services |
| **NIST 800-53** | CM-3 — Configuration Change Control | Conventional Commits provide structured change records |

### Organizational Controls

- **Customizable prompt templates** — enforce your commit message policies, scoping rules, and formatting standards
- **Pinned model versions** — no opaque model swaps by a cloud provider; you control what runs
- **Centralized deployment** — oh-my-zsh-style installer enables org-wide rollout via internal repos
- **Configuration hierarchy** — central defaults with per-developer overrides via `~/.aicommitrc`

---

## Quick Install

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/<user>/aicommit/main/install.sh)"
```

Or clone manually:

```bash
git clone https://github.com/<user>/aicommit.git ~/.aicommit
~/.aicommit/install.sh
```

### Prerequisites

- **[Ollama](https://ollama.ai/)** — local LLM runtime
- **qwen2.5-coder** model (or configure a different model):
  ```bash
  ollama pull qwen2.5-coder:latest
  ```

---

## Usage

### `aicommit` — Interactive Commit

```bash
git add -p                # Stage your changes
aicommit                  # Generate and review commit message
```

**Options:**

| Flag | Description |
|------|-------------|
| `--help`, `-h` | Show usage |
| `--dry-run`, `-d` | Build prompt without calling LLM |
| `--verbose`, `-v` | Show temp file paths |
| `--regenerate`, `-r` | Re-run LLM on cached prompt |

### `aic` — Quick Auto-Commit

```bash
git add -p && aic         # Stage and auto-commit
```

---

## Configuration

Edit `~/.aicommitrc` to customize behavior:

```bash
# LLM model (must be available in Ollama)
AI_MODEL="qwen2.5-coder:latest"

# Custom prompt template
AI_PROMPT_FILE="$HOME/.aicommit/templates/prompt.txt"
```

---

## How It Works

1. Reads staged `git diff` and file metadata
2. Detects project type, change patterns, and upgrade signals
3. Builds enhanced context with change statistics and recent commit history
4. Assembles a prompt grounded in the Conventional Commits specification
5. Sends to the **local** Ollama LLM for commit message generation
6. Presents the message for review — or auto-commits with `aic`

> All processing happens on your machine. The LLM never sees your code from a remote server — it runs locally alongside your development environment.

---

## Cloud AI Tools vs. AI Commit

| Risk Vector | Cloud AI Tools | AI Commit |
|-------------|----------------|----------|
| Source code exposure to third party | ⚠️ Diffs sent to cloud API | ✅ None |
| Vendor lock-in | ⚠️ Tied to provider API/pricing | ✅ Open source, swappable local models |
| API key management | ⚠️ Keys must be secured and rotated | ✅ No keys needed |
| Compliance audit complexity | ⚠️ Must document data flows to vendor | ✅ Data never leaves the device |
| Model behavior changes | ⚠️ Provider can change model silently | ✅ Pinned local model version |
| Availability | ⚠️ Requires internet + vendor uptime | ✅ Works fully offline |
| Cost | ⚠️ Per-seat or per-token pricing | ✅ Zero marginal cost |

---

## Uninstall

```bash
~/.aicommit/uninstall.sh
```

---

## Architecture

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full technical architecture, data flow, and component breakdown.

---

## License

MIT
