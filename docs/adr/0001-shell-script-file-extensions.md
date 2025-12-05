# 0001 - Shell Script File Extensions

**Status:** Accepted  
**Date:** 2025-12-03  
**Deciders:** Marcelo Almeida (@marcelocra)

## Context

When creating shell scripts, there's a question about which file extension to use. The repository has multiple scripts that use Bash-specific features (arrays, `[[ ]]`, `${var//pattern}`, etc.), but they're named with `.sh` extension.

**The issue:**

- `.sh` is traditionally associated with POSIX shell scripts
- Scripts using bashisms (Bash-specific features) may not run on other POSIX shells like dash
- The shebang (`#!/bin/bash`) defines the interpreter, but the extension provides visual documentation
- Tools like ShellCheck use the extension (and shebang) to determine which rules to apply

## Decision

Use file extensions that match the target shell:

| Extension | Use when                                                    |
| --------- | ----------------------------------------------------------- |
| `.bash`   | Script uses Bash-specific features (bashisms)               |
| `.sh`     | Script is POSIX-compliant (can run on dash, sh, bash, etc.) |
| `.zsh`    | Script uses Zsh-specific features                           |

**Rationale:** Being explicit about shell requirements provides:

1. Better documentation at a glance
2. Correct linting behavior in editors/tools
3. Clear communication of portability expectations

## Alternatives Considered

### Option 1: Use `.sh` for everything

**Rejected** because:

- Ambiguous - doesn't communicate portability
- Relies solely on shebang for shell identification
- Common convention, but technically imprecise
- Can mislead users about script requirements

### Option 2: No extension (rely on shebang only)

**Rejected** because:

- Harder to identify shell scripts in file listings
- File managers/editors may not detect type correctly
- Less discoverable in searches (e.g., `*.bash`)
- Requires reading file content to determine type

### Option 3: Use `.shell` generic extension

**Rejected** because:

- Non-standard
- No tooling support
- Doesn't solve the portability communication problem

## Commands vs. Scripts

An additional distinction applies based on how the file is used:

| Type                                      | Extension     | Reason                                                                        |
| ----------------------------------------- | ------------- | ----------------------------------------------------------------------------- |
| **Commands** (in `PATH`, invoked by name) | No extension  | Users type `ai-dev`, not `ai-dev.bash`. The shebang handles execution.        |
| **Sourced scripts**                       | Use extension | These are `source`d into the current shell. Extension documents requirements. |
| **Standalone scripts**                    | Use extension | Run with explicit path (`./install.sh`). Extension aids discoverability.      |

### Examples from this repository

| File                        | Type                  | Current               | Should be                          |
| --------------------------- | --------------------- | --------------------- | ---------------------------------- |
| `cli/ai-dev.sh`             | Command (in PATH)     | `ai-dev.sh`           | `ai-dev`                           |
| `shell/init.sh`             | Sourced (as `.zshrc`) | `init.sh`             | `init.bash`                        |
| `shell/x-archives.sh`       | Sourced               | `x-archives.sh`       | `x-archives.bash`                  |
| `install.sh`                | Standalone script     | `install.sh`          | `install.bash`                     |
| `setup/host-setup-linux.sh` | Standalone script     | `host-setup-linux.sh` | `host-setup-linux.bash`            |
| `apps/*/install.sh`         | Standalone scripts    | `install.sh`          | `install.bash` (if using bashisms) |

## Consequences

### Positive

- **Self-documenting** - File extension immediately communicates requirements
- **Better tooling** - ShellCheck and editors apply correct rules automatically
- **Explicit portability** - Clear distinction between portable and Bash-specific scripts
- **Easier auditing** - Can quickly identify which scripts need Bash vs generic shell

### Negative

- **Migration effort** - Existing `.sh` files using bashisms should be renamed
- **Slightly less common** - `.sh` is more frequently seen, but `.bash` is well-recognized and used by major projects (Homebrew, many Linux distros' scripts)
- **Learning curve** - Contributors need to know the convention

### Neutral

- Shebang remains the source of truth for execution
- No runtime behavior change - only naming convention
- Can be adopted incrementally

## Notes

**Examples of bashisms that warrant `.bash` extension:**

- Arrays: `arr=(one two three)`
- Extended test: `[[ $var =~ regex ]]`
- String manipulation: `${var//pattern/replacement}`
- Here strings: `<<< "string"`
- Process substitution: `<(command)`
- `source` vs `.` (though `source` works in most modern shells)

## Migration

**Strategy:**

1. Audit existing `.sh` files for bashisms
2. Rename files with bashisms to `.bash`
3. Remove extension from command scripts intended for `PATH`
4. Update any references (scripts, documentation, symlinks)
5. Apply convention to new scripts going forward

**Tracking:** See [GitHub Issue #TBD] for migration progress checklist.

**References:**

- [ShellCheck - shell dialect detection](https://www.shellcheck.net/)
- [POSIX Shell specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Bash-specific features (bashisms)](https://mywiki.wooledge.org/Bashism)
