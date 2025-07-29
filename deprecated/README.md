# Deprecated Configuration Files

⚠️ **DEPRECATED** - This directory contains deprecated/legacy configuration files that will be removed.

## Important Notice

**DO NOT USE OR RELY ON THESE FILES**

This directory contains old configuration files that have been replaced by the new, consolidated configuration system. These files are kept temporarily to:

1. **Surface hidden dependencies** - If something breaks, it indicates a dependency that needs to be migrated
2. **Reference during migration** - Compare old implementations with new ones during the transition
3. **Temporary fallback** - Only as a last resort during emergency situations

## Migration Status

The following files have been **replaced** by the new configuration system:

- **`../init.sh`** → Merged into `../shell/main.sh` with Google Shell Style Guide compliance
- **`../common.sh`** → Useful functions extracted to TODO section in `../shell/main.sh`

## New Configuration Location

The active configuration is now located at:

```
../shell/main.sh
```

This new system provides:

- ✅ **Google Shell Style Guide compliance**
- ✅ **Multi-platform support** (Ubuntu, Alpine, openSUSE)
- ✅ **Better organization** with clear sections and navigation markers
- ✅ **Consistent naming** with underscore-based function namespacing
- ✅ **Enhanced error handling** and safety checks
- ✅ **Single source of truth** for shell configuration

## If Something Breaks

If you encounter issues after the migration:

1. **First**: Check if the functionality exists in the new `../shell/main.sh`
2. **Then**: Look in the TODO section of `../shell/main.sh` for extracted functions
3. **Finally**: Temporarily reference files here to understand what needs to be migrated
4. **Always**: Update the new configuration instead of relying on these deprecated files

## Cleanup Timeline

These files will be **permanently deleted** once:

- [ ] All dependencies have been identified and migrated
- [ ] New configuration has been tested across all environments
- [ ] No functionality regressions have been reported for 30+ days

## Questions?

If you need to understand what a deprecated file did or how to migrate functionality:

1. Check the `../CLAUDE.md` context file for detailed migration documentation
2. Review the shell configuration refactoring section for technical details
3. Compare with the organized sections in the new `../shell/main.sh`

---

**Remember**: Using these deprecated files prevents complete migration and maintains technical debt. Always migrate functionality to the new system instead of relying on legacy implementations.
