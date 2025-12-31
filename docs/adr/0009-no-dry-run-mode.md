# 9. No Dry-Run Mode

Date: 2025-12-30

## Status

Accepted

## Context

During the December 2025 refactoring of the install script, a `--dry-run` mode was added. The intent was:
- Preview what the script would do before running it
- Help with debugging during development
- Allow safe testing on production machines

This was implemented via a `run_cmd` wrapper function that would either execute or print commands based on a `DRY_RUN` flag.

### Problems encountered

1. **Wrapper overhead** - Every command needed `run_cmd` wrapping
2. **Piped commands were awkward** - `run_cmd curl ... | run_cmd bash` was ugly and error-prone
3. **Copy/paste friction** - Official installation instructions had to be modified to add the wrapper
4. **Inconsistent coverage** - Not all commands were wrapped, making dry-run incomplete

## Decision

Remove dry-run support entirely. The added complexity was not worth the benefit.

### Why it's okay to remove

1. **Functions are already idempotent** - Each install function checks "is X already installed?" before doing anything. Re-running is safe.
2. **Docker tests verify real execution** - We test in actual containers, not with dry-run simulation
3. **Logging shows what happens** - `log_info` statements document execution flow, along with `log_debug` for tracing
4. **Code is readable** - Just read the script to see what it does
5. **Official instructions copy/paste** - No wrapper means we can use vendor instructions verbatim (e.g. github cli install)

## Consequences

### Positive
- Simpler code (no wrapper function)
- Easier to copy/paste official installation instructions
- Reduced cognitive overhead

### Negative
- Cannot preview without executing (mitigated by reading code or using Docker test)
