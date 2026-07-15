# GitHub Setup & Push Guide

How to publish the Sankalpa meta-repo and its component submodules to GitHub, and how to push changes day-to-day. This is a multi-repo project composed with git submodules (see [`../README.md`](../README.md), [`../COMPONENTS.md`](../COMPONENTS.md)).

> **The one rule that matters:** the meta-repo pins each component to a **specific commit**, so that commit must exist on the component's remote **before** the meta-repo is pushed or cloned. Therefore: **push the component repo first, then the meta-repo.** The helper config in §6 makes git enforce this for you.

---

## 0. Prerequisites

- Git installed, and you can authenticate to GitHub over **HTTPS** (a Personal Access Token via a credential helper) or **SSH** (an SSH key).
- Optionally the [GitHub CLI](https://cli.github.com/) (`gh`) — it creates repos and pushes in one step (Path A). Otherwise use the browser + git (Path B).

Set your GitHub owner once per shell (used throughout):

```bash
OWNER=dhiraj-salian               # this project's GitHub owner (change if forking)
```

Pick a URL style (used below as `<spec-url>` / `<meta-url>`):

| Style | sankalpa-spec | sankalpa (meta) |
|-------|---------------|-----------------|
| HTTPS | `https://github.com/$OWNER/sankalpa-spec.git` | `https://github.com/$OWNER/sankalpa.git` |
| SSH   | `git@github.com:$OWNER/sankalpa-spec.git` | `git@github.com:$OWNER/sankalpa.git` |

The rest of this guide uses HTTPS; substitute the SSH URLs if you prefer.

---

## 1. First-time publish

> **This clone's remotes are already configured over SSH** for `dhiraj-salian` (meta `origin` → `git@github.com:dhiraj-salian/sankalpa.git`; `sankalpa-spec` `origin` → `git@github.com:dhiraj-salian/sankalpa-spec.git`). So the quickest publish is: create the two **empty** GitHub repos, then push **component first, then meta**:
> ```bash
> git -C sankalpa-spec push -u origin main    # component first
> git push -u origin main                       # then the meta-repo
> ```
> Paths A and B below are the full from-scratch reference (e.g. for a fresh fork where remotes aren't set yet).

### Path A — with the GitHub CLI (recommended)

```bash
cd ~/Development/projects/sankalpa

# 1) Create + push the COMPONENT repo first (from inside the submodule).
cd sankalpa-spec
gh repo create $OWNER/sankalpa-spec --private --source=. --remote=origin --push
cd ..

# 2) Point the meta-repo's submodule URL at the real remote and record it.
git submodule set-url sankalpa-spec https://github.com/$OWNER/sankalpa-spec.git
git submodule sync
git commit -am "Point sankalpa-spec submodule at its GitHub remote"

# 3) Create + push the META repo (its pin now references a pushed commit).
gh repo create $OWNER/sankalpa --private --source=. --remote=origin --push
```

Use `--public` instead of `--private` if you want public repos.

### Path B — manual (browser + git)

1. On github.com, create **two empty repositories** — `sankalpa-spec` and `sankalpa` — with **no** auto-added README/.gitignore/license (the repos already have content locally; auto-init causes conflicts).

2. Push the **component** first:
   ```bash
   cd ~/Development/projects/sankalpa/sankalpa-spec
   git remote add origin https://github.com/$OWNER/sankalpa-spec.git
   git push -u origin main
   ```

3. Point the meta-repo's submodule at the remote:
   ```bash
   cd ~/Development/projects/sankalpa
   git submodule set-url sankalpa-spec https://github.com/$OWNER/sankalpa-spec.git
   git submodule sync
   git commit -am "Point sankalpa-spec submodule at its GitHub remote"
   ```

4. Push the **meta** repo:
   ```bash
   git remote add origin https://github.com/$OWNER/sankalpa.git
   git push -u origin main
   ```

---

## 2. Verify it worked

Clone the whole project fresh into a temp directory and confirm the submodule materializes:

```bash
git clone --recursive https://github.com/$OWNER/sankalpa.git /tmp/sankalpa-verify
ls /tmp/sankalpa-verify/sankalpa-spec/spec   # should list the Books
rm -rf /tmp/sankalpa-verify
```

If `sankalpa-spec/` is empty after a normal clone, the cloner forgot `--recursive`; they can fix it with `git submodule update --init --recursive`.

---

## 3. Everyday workflow — pushing changes

### A) You changed a **component** (e.g. the spec)

```bash
# 1) Commit & push inside the COMPONENT repo:
cd ~/Development/projects/sankalpa/sankalpa-spec
git add -A
git commit -m "Describe the spec change"
git push                                  # -> github.com/$OWNER/sankalpa-spec

# 2) The meta-repo now sees the submodule pointer moved. Record the new pin:
cd ..
git add sankalpa-spec
git commit -m "Bump sankalpa-spec pin"
git push                                  # -> github.com/$OWNER/sankalpa
```

> Pushing the component does **not** move the meta pin automatically — step 2 records which component commit is now part of the project. Always do the component push (step 1) before the meta push (step 2).

### B) You changed only **meta-level** files (README, COMPONENTS, scripts)

```bash
cd ~/Development/projects/sankalpa
git add -A
git commit -m "Update umbrella docs"
git push
```

---

## 4. Working on another machine / after teammates push

```bash
# Get meta changes AND move submodules to the newly-pinned commits:
git pull
git submodule update --init --recursive
```

After `git submodule update`, a submodule is on a **detached HEAD** at the pinned commit (normal). To make changes in it, check out the branch first:

```bash
cd sankalpa-spec
git checkout main
git pull                                   # catch up to the component's latest
```

---

## 5. Adding a new component later (per COMPONENTS.md)

When a roadmap phase begins and a new component repo is created:

```bash
cd ~/Development/projects/sankalpa
# (create the repo first, e.g. `gh repo create $OWNER/sankalpa-core --private`)
git submodule add https://github.com/$OWNER/sankalpa-core.git sankalpa-core
git commit -m "Add sankalpa-core component (Phase 3)"
git push
# Then add a row to COMPONENTS.md.
```

---

## 6. Recommended git config (do this once)

Make submodules safer and less fiddly:

```bash
# Auto-recurse into submodules on pull/checkout so they track the pins:
git config --global submodule.recurse true

# Refuse to push a meta commit whose submodule commits aren't on their remotes yet
# (this enforces "component first" automatically):
git config --global push.recurseSubmodules check
# ...or push submodules automatically when you push the meta-repo:
# git config --global push.recurseSubmodules on-demand
```

---

## 7. Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `sankalpa-spec/` empty after clone | Cloned without `--recursive`. Run `git submodule update --init --recursive`. |
| Meta clone fails to fetch submodule | The pinned component commit isn't on its remote, or `.gitmodules` still says `OWNER`. Push the component; fix the URL with `git submodule set-url … && git submodule sync`. |
| `fatal: detected dubious ownership` | Run `git config --global --add safe.directory <path>` for the repo path. |
| Submodule "modified" in `git status` but you didn't touch it | It moved to a new commit (you or a pull). `git add <submodule> && git commit` to record the pin, or `git submodule update` to reset it to the pinned commit. |
| Auth prompts / failures over HTTPS | Set up a credential helper + PAT, or switch the remotes to SSH URLs. `gh auth login` configures this for you. |
| Pushed meta but teammates can't get the component | You pushed the meta pin but not the component commit. Push the component repo; consider `push.recurseSubmodules=check` (§6). |
