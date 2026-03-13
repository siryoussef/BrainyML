# Step 0: Project Scaffolding

**Status:** ✅ Complete

## What was done
1. Initialized git repo at `/Shared/@Repo/BrainyML`.
2. Created directory structure: `docs/`, `unison/`, `scripts/`, `skill/`, `shared-files/`, `_agents/`.
3. Created `flake.nix` (devenv flake with nixpkgs-unstable input).
4. Created `devenv.nix` (Unison, Python 3.12 w/ venv, jq, git).
5. Created `devenv.yaml` (nixpkgs input).
6. Created `.gitignore` (ignores `.devenv/`, `__pycache__/`, `submodules/NELL/`, etc).
7. Created `scripts/requirements.txt` (pandas, click, rdflib).
8. Created `README.md` and `docs/architecture.md`.

## Verification
Run `devenv shell` to confirm all tools are available:
```bash
cd /Shared/@Repo/BrainyML && devenv shell
# Inside shell: ucm --version && python3 --version && jq --version
```

## Next
Proceed to `docs/steps/step1-submodules.md`.
