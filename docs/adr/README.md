# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the dotfiles repository.

## What is an ADR?

An Architecture Decision Record (ADR) captures an important architectural decision made along with its context and consequences. ADRs help understand:

- Why certain decisions were made
- What alternatives were considered
- What the trade-offs and consequences are

## Format

We use a simplified version of [Michael Nygard's ADR template](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).

Each ADR contains:

1. **Title** - Short present-tense statement
2. **Status** - Proposed, Accepted, Rejected, Deprecated, Superseded
3. **Context** - What is the issue motivating this decision
4. **Decision** - What change we're proposing and/or doing
5. **Alternatives Considered** - Other options and why they were rejected
6. **Consequences** - What becomes easier or harder to do

## Naming Convention

ADRs are numbered sequentially and use lowercase with dashes:

- `0001-shell-script-file-extensions.md`

## Creating a New ADR

1. Copy an existing ADR or use the format above
2. Assign the next sequential number
3. Fill in all sections
4. Start with status "Proposed"
5. After consideration, change to "Accepted" or "Rejected"
6. Commit to the repository

## Index

| ADR                                          | Title                              | Status   |
| -------------------------------------------- | ---------------------------------- | -------- |
| [0001](0001-shell-script-file-extensions.md) | Shell Script File Extensions      | Accepted |
| [0002](0002-monolithic-install-script.md)    | Monolithic Install Script          | Accepted |
| [0003](0003-locale-and-timezone-configuration.md) | Locale and Timezone Configuration | Accepted |
| [0004](0004-environment-detection.md)        | Environment Detection              | Accepted |
| [0005](0005-development-tool-selection.md)   | Development Tool Selection         | Accepted |
| [0006](0006-network-security-tailscale.md)   | Network Security with Tailscale    | Accepted |
| [0007](0007-package-manager-pnpm.md)        | Package Manager Choice: pnpm       | Accepted |
| [0008](0008-stability-over-latest.md)       | Stability Over Latest Philosophy   | Accepted |
| [0009](0009-no-dry-run-mode.md)              | No Dry-Run Mode                   | Accepted |
| [0010](0010-standard-config-directory.md)    | Standard Config Directory Location | Accepted |
