# Dotfiles Refactoring Plan

## Goal

Make the dotfiles installation "world-class" with reliability, testing, and code quality.

## Current Status: Phase 1 Complete ✅

## Roadmap

### Phase 1: Foundation & Script Enhancement ✅
- [x] Create `PLAN.md`
- [x] Create ADRs (0001-0008)
- [x] Unify flag patterns (`SKIP_*`)
- [x] Add locale exports (`TZ`, `LANG`, `LC_ALL`, `LC_TIME`)
- [x] Add gh CLI installation
- [x] Add extra tools (zoxide, eza, delta, lazygit, tldr, htop) via `--with-extras`
- [x] ~~Add cloud tools~~ (removed - install manually if needed)
- [x] Add shellcheck/shfmt to brew packages
- [x] Consolidate `AGENTS.md` (deleted `AI_CONTEXT.md`)
- [x] Rename test scripts to `.bash`

### Phase 2: Testing & CI
- [ ] Create `.github/workflows/test.yml`
- [ ] Add shellcheck/shfmt pre-commit hooks
- [ ] Verify all tests pass

### Phase 3: ADR Clarifications
- [ ] Update ADR-0001 with `x-[command]` naming convention

### Phase 4: Cutover
- [ ] Update root `install.bash` to call `setup/install.bash`
- [ ] Convert `shell/install.sh` to warning stub

### Phase 5: Cleanup
- [ ] Rename `.sh` → `.bash` for Bash-specific scripts
- [ ] Consider flag pattern change (`SKIP_*` → more intuitive)
- [ ] Review `deprecated/` directory

### Phase 6: Nix Evaluation
- [ ] Research Nix/NixOS for cloud VM provisioning
- [ ] Create proof-of-concept Nix configuration
- [ ] Document decision in ADR
