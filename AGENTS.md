# Repository Guidelines

## Project Structure & Module Organization
The repository is intentionally slim: `Dockerfile` defines the CUDA-enabled builder image, `compile_outside.sh` orchestrates host-side matrix builds, and `compile_inside.sh` runs inside the container to produce wheels. Place generated artifacts under `wheels/` or another ignored directory; avoid committing built wheels. Any new helper scripts should live beside the existing Bash entry points for discoverability. Default support is scoped to PyTorch `2.9.0+cu128`; document and test thoroughly if you extend beyond that matrix.

## Build, Test, and Development Commands
- `docker build -t pytorch3d_builder:cu128 .` — create the CUDA 12.8 base builder image; adjust tag if you fork variants.
- `./compile_outside.sh "3.12 3.13" "2.9.0:128" "0.7.8" ./wheels/` — supported matrix targeting PyTorch 2.9.0 + CUDA 12.8; pass space-delimited Python versions, torch:cuda pairs, pytorch3d versions, and an output directory.
- `docker run -it --rm -v $(pwd):/builder pytorch3d_builder:cu128 bash` — ad-hoc shell for debugging inside the image.

## Coding Style & Naming Conventions
Author Bash scripts with `#!/bin/bash`, 4-space indentation, and defensive quoting (e.g., wrap variables that can contain whitespace). Favor descriptive, lowercase-with-underscores variable names (`PYTORCH3D_VERSIONS`) that mirror existing scripts. Keep Dockerfile instructions grouped by purpose and collapse multi-line `RUN` blocks with backslashes aligned under the command.

## Testing Guidelines
There is no automated test suite; validate changes by running the supported matrix via `compile_outside.sh` (Python 3.12 and 3.13 with CUDA 12.8) and inspecting the resulting `.whl` names. When altering build flags, run one build per CUDA variant to confirm `NVCC_FLAGS` and the generated `__version__` tag look correct. Record any manual verification steps in the pull request to keep reviewers aligned.

## Commit & Pull Request Guidelines
Commits follow short, imperative summaries (`Update README.md`, `Add files`); keep them under 60 characters and focused. Develop on feature branches named `feature/<topic>` or `fix/<topic>` and keep history linear via rebase before opening a PR. Reference related issues in the body and explain matrix choices or environment requirements. Pull requests should include: a concise description, example command invocation, confirmation of smoke builds (local or CI), and notes on any external dependencies or credentials needed.

## Environment & Security Notes
Avoid embedding credentials in scripts—pass secrets via environment variables or Docker runtime flags. Update the base image tag deliberately; align CUDA/PyTorch compatibility before pushing. Document any host requirements (GPU drivers, Docker configuration) whenever they change. When tweaking CI, keep the `Build Wheels` workflow self-contained so it uses only repository scripts and the default `GITHUB_TOKEN`.
