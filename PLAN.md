# Dotfiles Refactoring Plan

## Goal
Make the dotfiles installation "world-class" by improving reliability, testing, and code quality, while preserving the simplicity of the single-script usage.

## Roadmap

- [ ] **Phase 1: Foundation & Documentation**
    - [ ] Create `PLAN.md` (This file).
    - [ ] Create ADR 0002 documenting the "Monolithic Script" decision.
    - [ ] Create `task.md` to track immediate steps.

- [ ] **Phase 2: Testing Infrastructure**
    - [ ] Create `tests/docker-test.sh` to provide a safe, clean integration test environment.
    - [ ] Ensure the current script passes the test before refactoring.

- [ ] **Phase 3: Refactoring `shell/install.sh`**
    - [ ] Implement robust argument parsing (flags instead of just env vars).
    - [ ] Centralize version definitions at the top of the file.
    - [ ] Improve idempotency checks (verify state before acting).
    - [ ] Add `dry-run` mode for safety.

- [ ] **Phase 4: Cleanup**
    - [ ] Identify truly unused/legacy files.
    - [ ] Move them to `deprecated/` or delete them.
