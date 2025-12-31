# 7. Package Manager Choice: pnpm

Date: 2025-12-30

## Status

Accepted

## Context

Node.js development requires a package manager for installing dependencies. The main options are:
- **npm** - Default, bundled with Node.js
- **yarn** - Facebook's alternative (v1 and v3/berry)
- **pnpm** - Performant npm alternative with strict dependency management

## Decision

We will use **pnpm** exclusively, with no npm fallback.

### Rationale

| Aspect | npm | pnpm |
|--------|-----|------|
| Speed | Baseline | 2-3x faster |
| Disk usage | Duplicates per project | Shared content-addressable store |
| Strictness | Allows phantom dependencies | Strict, prevents undeclared deps |
| Monorepo support | Workspaces (basic) | Workspaces + filtering (superior) |
| Compatibility | Universal | 99.9% compatible |

### Why No npm Fallback

1. **Consistency** - One tool, one lockfile format, one workflow
2. **Performance** - npm is noticeably slower, especially in CI
3. **Correctness** - pnpm's strict mode catches dependency issues early
4. **Deliberate choice** - If a project requires npm, it's a conscious decision, not a default

### Implementation

```bash
# Installation
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Global packages
pnpm add -g @anthropic-ai/claude-code @google/gemini-cli ...

# Aliases in init.sh
alias p="pnpm"
alias pf="pnpm --filter"
```

## Consequences

### Positive
- Faster installations (locally and in CI)
- Less disk space usage
- Catches dependency issues that npm misses
- Superior monorepo filtering

### Negative
- Some legacy projects may require npm (rare)
- Team members unfamiliar with pnpm need brief onboarding
- Some CI templates assume npm (easily changed)
