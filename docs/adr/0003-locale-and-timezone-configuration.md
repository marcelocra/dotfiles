# 3. Locale and Timezone Configuration

Date: 2025-12-30

## Status

Accepted

## Context

Development machines need consistent locale and timezone settings to prevent issues with:
- Git filename encoding (corrupted non-ASCII characters)
- Log timestamps across multiple VMs
- Script behavior depending on locale-specific patterns (sorting, regex)
- Date/time formatting in output

Cloud VMs typically default to UTC timezone and `C.UTF-8` or minimal locale, which can cause:
- Confusion when reading logs (UTC vs local time)
- Encoding issues with non-ASCII filenames in git

## Decision

We will configure the following environment variables in `shell/init.sh`:

```bash
export TZ="America/Sao_Paulo"
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"
export LC_TIME="en_GB.UTF-8"  # day/month/year, 24h time
```

Additionally, the install script (`setup/install.bash`) will set the system timezone via `timedatectl` when available.

### Rationale for `C.UTF-8` over `en_US.UTF-8`

| Aspect | `C.UTF-8` | `en_US.UTF-8` |
|--------|-----------|---------------|
| Sorting | Byte-wise (deterministic) | Case-insensitive, locale-aware |
| Regex | POSIX-consistent | Locale-dependent |
| Performance | Faster | Slightly slower |
| Scripting | Predictable | May have surprises |

### Rationale for `en_GB.UTF-8` as `LC_TIME`

Provides day/month/year date format (31/12/2025) and 24-hour time format, which is the owner's preference.

## Consequences

### Positive
- Consistent behavior across all VMs and containers
- No more encoding issues with git filenames
- Timestamps in logs use Sao Paulo timezone
- Date/time output uses preferred format

### Negative
- Requires `locale-gen` to generate `en_GB.UTF-8` on some systems
- Different from cloud provider defaults (requires explicit setting)
