# 2. Monolithic Install Script

Date: 2025-12-30

## Status

Accepted

## Context

We need to provide a "world-class" dotfiles installation experience that remains simple to use, maintain, and understand. The previous implementation was a large single script (`shell/install.sh`), which had the benefit of simplicity (one file to read, one entry point) but lacked improved engineering practices (robust argument parsing, testing, isolation).

We considered breaking this script into multiple smaller modules (e.g., `setup/lib/sys_packages.sh`, `setup/lib/cli_tools.sh`) to improve separation of concerns.

## Decision

We will **maintain the monolithic script architecture** (`shell/install.sh`) as the core installation logic, but we will apply rigorous software engineering practices *within* that single file.

We effectively treat the single file as a module with distinct, well-isolated sections (acting like "namespaces" or "classes").

Key practices to be enforced within this file:
1.  **Strict Mode**: `set -euo pipefail` must be enabled.
2.  **Top-Level Config**: All versions and configuration variables must be defined at the top.
3.  **Code Quality**: Use `shellcheck` and `shfmt` to ensure code quality.
4.  **Testing**: The script must be verifyable via a Docker-based integration test (`tests/docker-test.sh`).

## Consequences

### Positive
- **Simplicity**: Users (and the author) only need to know about one file. There is no cognitive load of understanding a complex directory structure for the installer.
- **Portability**: The script is a self-contained unit (mostly) that can be easily copied or curled.
- **Maintainability**: Debugging involves looking at a single flow of execution in one file.

### Negative
- **File Size**: The file may become large (1000+ lines). We mitigate this by using code folding (markers) and strict organization.
- **Collision**: Multiple developers editing different parts of the file might cause merge conflicts (less likely in a dotfiles repo).
