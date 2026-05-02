# code-server-singularity

Singularity/Apptainer container image definition for [code-server](https://github.com/coder/code-server) — VS Code in the browser.

## Outline

- This repository provides a Singularity definition file for code-server.
- The container is intended for browser access on localhost.
- Use SSH port forwarding when accessing from a remote client.
- Change the default port for your own environment as needed.

## Project artifacts

This repository's **final deliverables** are:

- `code-server.def` — Singularity/Apptainer definition file
- `scripts/build_sif.sh` — Build helper script
- `scripts/test_sif.sh` — Smoke test validation script
- `README.md` and documentation

**Note:** Generated `.sif` container images are **not** committed to version control. They must be built locally using `scripts/build_sif.sh`; see [Building the image locally](#building-the-image-locally) below.

## Building the image locally

Requires [Singularity](https://sylabs.io/singularity/) ≥ 3.8.6 or [Apptainer](https://apptainer.org/). For your test environment, Singularity 3.8.6 via conda is also acceptable.

The build script tries `--fakeroot` first. If that fails and `sudo` is available, it automatically retries without `--fakeroot`.

Built images are stored in the repository-local `sif/` directory (see [.gitignore](.gitignore)):

```bash
# Build (output: sif/code-server_4.117.0.sif)
./scripts/build_sif.sh

# Build with a specific code-server version
./scripts/build_sif.sh 4.117.0
```

## Testing a built image

This repository includes a smoke test that validates commands from the built image:

- `code-server --help`
- `code-server --version`

```bash
# Test the latest built image from sif/
./scripts/test_sif.sh

# Test an explicit image path
./scripts/test_sif.sh ./sif/code-server_4.117.0.sif
```

## Local full checks before PR

Before opening a pull request, run full local verification (build + smoke test + lightweight checks):

```bash
./scripts/local_full_check.sh
```

If you use conda-managed Singularity:

```bash
SINGULARITY_CMD="conda run -n nf-env singularity" ./scripts/local_full_check.sh
```

GitHub Actions runs only lightweight checks:

```bash
./scripts/ci_check.sh
```

## Usage examples

```bash
# Run with default settings (listens on 127.0.0.1:8080)
singularity run code-server.sif

# Use a custom localhost port
singularity run code-server.sif --bind-addr 127.0.0.1:18080

# Bind a local directory and open it as the workspace
singularity run --bind /path/to/project:/workspace code-server.sif /workspace

# Pass through the host network namespace
singularity run --net code-server.sif
```

**Security note:** Avoid exposing code-server with `0.0.0.0` unless you are intentionally publishing the service and have proper network controls and authentication in place.
