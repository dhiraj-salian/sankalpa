# Sankalpa (संकल्प)

> **Intent · Resolve · Determination.**
> An open-source operating system for intelligent work that transforms human **intent** into **deterministic execution**.

This is the **umbrella (meta) repository** for the Sankalpa project. It does not contain source itself — it **composes** the project's component repositories as [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so each component is maintained as its own independent repository on GitHub, while this repository lets you clone, browse, and work with all of them **together** — both locally and on GitHub.

If you are new to Sankalpa, start with the specification: [`sankalpa-spec/`](sankalpa-spec/README.md).

---

## Why a meta-repo of submodules

Sankalpa is a platform with a specification and (over time) several independent implementation components (kernel, resource model, IR, compiler, runtimes, …). We want two things that are usually in tension:

1. **Independent components** — each repo has its own issues, releases, versioning, CI, and maintainers. You can clone and work on one without the rest.
2. **A coherent whole** — a single place that pins a *consistent, working set* of component versions, so anyone can check out the entire project in one command and see how the pieces fit.

Git submodules give us exactly this. This meta-repo records, for each component, **which commit** of that component belongs to the current consistent set (a "gitlink"). Cloning this repo `--recursive` materializes every component at its pinned commit; on GitHub, each submodule appears as a link to its own repository at that commit.

**Alternatives we rejected:** a single monorepo would forfeit independent per-component repos (a hard requirement); `git subtree` would blur the components' histories and make separate maintenance awkward. Submodules keep the histories cleanly separate while still assembling them here.

## Repository layout

```
sankalpa/                    ← this umbrella meta-repo  (github.com/OWNER/sankalpa)
├── README.md                ← you are here
├── COMPONENTS.md            ← the component map: repos, status, roadmap phase
├── .gitmodules              ← declares each component submodule + its remote URL
├── scripts/
│   ├── bootstrap.sh         ← clone/init all submodules and set them up
│   └── update-all.sh        ← pull the latest of each submodule and re-pin
└── sankalpa-spec/           ← submodule → github.com/OWNER/sankalpa-spec   [Draft-complete]
    (future components are added as submodules as their ROADMAP phase begins)
```

See [`COMPONENTS.md`](COMPONENTS.md) for the full, current list of component repositories and their status.

## Getting started

### Clone everything together

```bash
# Clone the meta-repo AND all component repos at their pinned commits:
git clone --recursive https://github.com/OWNER/sankalpa.git

# Already cloned without --recursive? Initialize the submodules:
cd sankalpa
git submodule update --init --recursive
# …or:
./scripts/bootstrap.sh
```

### Work on a single component independently

Each component is a normal, standalone repository. You can ignore this meta-repo entirely and just:

```bash
git clone https://github.com/OWNER/sankalpa-spec.git
```

Changes are made, reviewed, and released in the **component** repo. The meta-repo is updated separately to *point at* a new component commit (see below).

### Update the pinned set

```bash
# Pull the latest commit of every submodule and re-pin this meta-repo to them:
./scripts/update-all.sh
git commit -am "Update component pins"
```

Pinning is intentional: the meta-repo always references a **specific, known-good commit** of each component, so the assembled whole is reproducible. You advance the pins deliberately, not automatically.

## Governance and structure

Sankalpa is **specification-first** (see [ADR-0001](sankalpa-spec/adrs/0001-specification-first-development.md)): the architecture is authored and stabilized in [`sankalpa-spec`](sankalpa-spec/README.md) before implementation begins. The specification is currently **Draft-complete** across all 16 Books; implementation components (kernel, ARM, IR, compiler, …) are created as their [roadmap](sankalpa-spec/ROADMAP.md) phases begin, each as a new component repo added here as a submodule.

Project-wide governance, the RFC/ADR/AEP process, and contribution guidelines live in the specification repo ([`GOVERNANCE.md`](sankalpa-spec/GOVERNANCE.md), [`CONTRIBUTING.md`](sankalpa-spec/CONTRIBUTING.md), [`process/`](sankalpa-spec/process/README.md)) and apply across all component repos.

## Setting up the GitHub remotes (one-time)

This meta-repo is wired with placeholder remote URLs (`github.com/OWNER/...`). To publish:

1. Create the GitHub repositories (e.g. `sankalpa` and `sankalpa-spec`) under your account/org.
2. Replace `OWNER` with your GitHub owner in [`.gitmodules`](.gitmodules) (or run `git submodule set-url sankalpa-spec <url>`), then `git submodule sync`.
3. Push each **component** repo first (so its commits exist on GitHub), then push this **meta** repo (whose gitlinks reference those commits).

See [`COMPONENTS.md`](COMPONENTS.md) §Publishing for the exact commands.

## License

The specification is licensed CC BY 4.0; code and schemas Apache-2.0 (see [`sankalpa-spec/LICENSE`](sankalpa-spec/LICENSE)). Each implementation component repo carries its own `LICENSE` (Apache-2.0).
