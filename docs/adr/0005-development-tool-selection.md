# 5. Development Tool Selection

Date: 2025-12-30

## Status

Accepted

## Context

A development machine requires various CLI tools. We need to decide:
1. Which tools to install by default vs. opt-in
2. Installation method for each tool
3. Trust/security criteria for tool selection

## Decision

### Default Tools (Always Installed)

| Tool | Purpose | Install Via |
|------|---------|-------------|
| git, curl, wget | Core utilities | apt |
| fzf | Fuzzy finder | Custom fork (clone + install) |
| ripgrep (rg) | Fast grep | Homebrew |
| bat | Better cat | Homebrew |
| fd | Better find | Homebrew |
| jq | JSON processor | apt |
| just | Task runner | Official installer |
| nvm + Node.js LTS | JavaScript runtime | Official installer |
| pnpm | Package manager | Official installer |
| gh | GitHub CLI | apt/Homebrew |
| shellcheck | Shell linting | apt/Homebrew |
| shfmt | Shell formatting | Homebrew |

### Opt-In Tools (`--with-extras`)

| Tool | Why Install It | Why Opt-In |
|------|----------------|------------|
| zoxide | Stop typing `cd ../../projects/myapp` — just type `z myapp` and teleport there | Changes navigation workflow |
| eza | `ls`, but beautiful. Colors, icons, git status in every listing | Cosmetic enhancement |
| delta | Git diffs that don't hurt your eyes. Syntax highlighting, side-by-side view | Requires git config changes |
| lazygit | Git without memorizing commands. Interactive staging, branching — all with arrow keys | Alternative workflow |
| tldr | Man pages are 500 lines. `tldr tar` gives you the 5 commands you actually need | Nice-to-have |
| htop | See what's eating your RAM. Kill it with one keypress | Not always needed |

### Cloud Tools (`--cloud-tools`)

| Tool | Purpose |
|------|---------|
| kubectl | Kubernetes CLI |
| terraform | Infrastructure as Code |
| aws-cli | AWS CLI |
| gcloud | Google Cloud CLI |
| azure-cli | Azure CLI |

### Security Criteria

Tools must meet one of:
1. Part of official distribution repositories (apt)
2. >10,000 GitHub stars with active maintenance
3. Official first-party installer (vendor-provided)
4. Forked to personal repository for control (e.g., fzf)

### Security Analysis (as of 2025-12-30)

**Evaluation criteria:**
- **Stars** - Community adoption (>10K = widely used)
- **Language** - Rust/Go preferred (memory safety)
- **Maintenance** - Active commits in last 6 months
- **Security policy** - SECURITY.md or vulnerability handling
- **CVE history** - Known issues and how quickly patched

| Tool | Stars | Language | Author | Security Notes |
|------|-------|----------|--------|----------------|
| bat | ~56K | Rust | sharkdp | ✅ No known CVEs, memory-safe |
| fd | ~41K | Rust | sharkdp | ✅ CVE-2024-24576 patched promptly |
| ripgrep | ~58K | Rust | BurntSushi | ✅ Vuln reporting process, widely used in VS Code |
| shellcheck | ~38K | Haskell | koalaman | ✅ v0.11.0 Aug 2025, updated for POSIX.1-2024 |
| shfmt | ~8.4K | Go | mvdan | ✅ Complementary to shellcheck, no known CVEs |
| babashka | ~4.4K | Clojure | borkdude | ✅ Known maintainer, EPL-1.0 license |
| zoxide | ~32K | Rust | ajeetdsouza | ✅ No advisories, active maintenance |
| eza | ~19K | Rust | eza-community | ✅ Has SECURITY.md, Feb 2024 CVE patched |
| delta | ~28K | Rust | dandavison | ✅ No advisories, syntax highlighting only |
| lazygit | ~69K | Go | jesseduffield | ✅ Handles vuln reports privately |
| tldr | ~60K | Various | tldr-pages | ✅ Low risk (displays text only) |
| htop | ~7K+ | C | htop-dev | ✅ Long-established (10+ years), stable |

## Consequences

### Positive
- Consistent tooling across all development environments
- Security-vetted selections
- Opt-in for workflow-changing tools prevents surprises

### Negative
- Homebrew dependency for some tools (adds installation time)
- Custom forks require periodic sync with upstream
