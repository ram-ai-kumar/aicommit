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

## What You Get

### Complete Change Attribution

Most AI commit tools capture the dominant change and lose the rest. AI Commit identifies every distinct concern in a commit — a tooling migration, a feature removal, a security patch — and documents each one. Your change history reflects reality, not a summary of the loudest diff.

This matters when a compliance audit, incident post-mortem, or code review requires a precise answer to *"what exactly changed and why?"*

### Sensitive Files Stay Out of AI

Environment variables, secrets, and credentials are excluded from AI analysis by design — even when staged. Generated artifacts, compiled outputs, and binary assets are similarly filtered. The AI sees only what is meaningful for understanding intent. Nothing more.

### Noise-Free, Authoritative Audit Trail

Conventional Commits enforced across every developer, every repository, every day. Machine-parseable commit history that feeds directly into changelog generation, release automation, and compliance reporting — without manual curation.

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
- **Secrets excluded from AI analysis** — `.env` files and credentials are filtered before LLM input, by design
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
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ram-ai-kumar/aicommit/main/install.sh)"
```

Or clone manually:

```bash
git clone https://github.com/ram-ai-kumar/aicommit.git ~/.aicommit
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

1. Reads staged changes and classifies every file by role — source, config, tests, infrastructure, documentation, assets
2. Filters AI input intelligently: secrets and credentials excluded, generated artifacts reduced to statistics, test and documentation files summarized
3. Identifies distinct change concerns across the diff — a feature addition, a tooling migration, a security removal — and preserves all of them
4. Assembles a focused prompt grounded in the Conventional Commits specification
5. Sends to the **local** Ollama LLM — never a remote server
6. Presents the complete, multi-concern commit message for review — or auto-commits with `aic`

> All processing happens on your machine. The LLM never sees your code from a remote server — it runs locally alongside your development environment.

---

## Cloud AI Tools vs. AI Commit

| Risk Vector | Cloud AI Tools | AI Commit |
|-------------|----------------|----------|
| Source code exposure to third party | ⚠️ Diffs sent to cloud API | ✅ None |
| Secrets in staged files exposed to AI | ⚠️ Sent as-is | ✅ Excluded by design |
| Vendor lock-in | ⚠️ Tied to provider API/pricing | ✅ Open source, swappable local models |
| API key management | ⚠️ Keys must be secured and rotated | ✅ No keys needed |
| Compliance audit complexity | ⚠️ Must document data flows to vendor | ✅ Data never leaves the device |
| Multi-change commit accuracy | ⚠️ Typically captures only dominant change | ✅ All distinct concerns documented |
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
