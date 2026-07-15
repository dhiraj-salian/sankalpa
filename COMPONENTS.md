# Sankalpa Components

This meta-repo composes the Sankalpa project's component repositories as git submodules. This document is the **map of record**: which repos exist, their status, and how they align to the [roadmap](sankalpa-spec/ROADMAP.md). Each component is an independent GitHub repository; this meta-repo pins a consistent set of their commits.

## Current components

| Component (submodule path) | Repository | Status | Roadmap phase |
|----------------------------|------------|--------|---------------|
| [`sankalpa-spec/`](sankalpa-spec/README.md) | `github.com/dhiraj-salian/sankalpa-spec` | **Draft-complete** (all 16 Books authored) | Phase 1–2 |

## Planned components

These are created as **new component repositories** and added here as submodules when their roadmap phase begins. Names are provisional and fixed by RFC/ADR when each is created. Implementation does not begin until the specification stabilizes at **v1.0** (Phase 2 gate, [ADR-0001](sankalpa-spec/adrs/0001-specification-first-development.md)).

| Planned component | Scope (spec reference) | Roadmap phase |
|-------------------|------------------------|---------------|
| `sankalpa-core` | Kernel, Event Bus, Resource Manager, Kernel API, Lifecycle, Controller Runtime, Plugin/Package Managers (Books 03, 07) | Phase 3 |
| `sankalpa-arm` | Agent Resource Model implementation (Book 02) | Phase 4 |
| `sankalpa-ir` | AOS IR data structures, verification, serialization (Book 04) | Phase 5 |
| `sankalpa-compiler` | Compiler pipeline: passes, optimization, policy validation, lowering (Book 05) | Phase 6 |
| `sankalpa-runtime-n8n` | First runtime compiler/backend — n8n (Book 06, AEP-0002) | Phase 7 |
| `sankalpa-knowledge` | Vault ⇄ graph knowledge system (Book 09) | Phase 8 |
| `sankalpa-secret-broker` | Secret Broker; credential acquisition (Book 11) | Phase 9 |
| `sankalpa-planner-sdk` | Planner interface / SDK (Book 08, AEP-0001) | Phase 10 |
| `sankalpa-planner-langgraph` | LangGraph planner adapter (Book 08 §Ch06) | Phase 11 |
| `sankalpa-experience` | Experience engine; determinization discovery (Book 10) | Phase 12 |
| `sankalpa-marketplace` | Package publishing, discovery, signing (Book 12) | Phase 13 |

> The exact repo boundaries (one repo vs. several) for each phase are decided by RFC when the phase begins — the spec's Book structure suggests the seams, but the repo split is an implementation decision, not fixed here. This table is the intent; it is updated as repos are actually created.

## Adding a new component

When a phase begins and a component repo is created:

```bash
# From the meta-repo root, once the component repo exists on GitHub:
git submodule add https://github.com/dhiraj-salian/sankalpa-core.git sankalpa-core
git commit -m "Add sankalpa-core component (Phase 3)"
# Then add a row to the 'Current components' table above.
```

## Publishing (one-time GitHub setup)

The remotes are already configured for owner **`dhiraj-salian`** (meta `origin` → `github.com/dhiraj-salian/sankalpa.git`; `sankalpa-spec` `origin` → `github.com/dhiraj-salian/sankalpa-spec.git`). Create the two empty GitHub repos, then push the **component first, then the meta-repo**:

```bash
git -C sankalpa-spec push -u origin main    # component first (its commits must exist remotely)
git push -u origin main                       # then the meta-repo (its pin references them)
```

The full walkthrough — setup, everyday change-and-push, cloning, adding components, and troubleshooting — is in [`docs/GITHUB-SETUP.md`](docs/GITHUB-SETUP.md).

## Why the component repo, not the meta-repo, is where work happens

- **Issues, PRs, releases, CI, versioning** live in each component repo — that is where a change to that component is proposed, reviewed, and released.
- The **meta-repo** only records *which commit* of each component forms the current consistent set. You advance a pin deliberately (`scripts/update-all.sh` or `git submodule update --remote`) and commit that pin here.
- This keeps components independently maintainable (the requirement) while giving one reproducible, assembled view of the whole project (the benefit).
