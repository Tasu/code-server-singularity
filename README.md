# code-server-singularity

Singularity/Apptainer container image definition for [code-server](https://github.com/coder/code-server) — VS Code in the browser.

## Outline

- This repository provides a Singularity definition file for code-server.
- The container is intended for browser access on localhost.
- Use SSH port forwarding when accessing from a remote client.
- Change the default port for your own environment as needed.

## Quick start

Download the latest `.sif` image from the [Releases](https://github.com/Tasu/code-server-singularity/releases) page, then run:

```bash
singularity run code-server_<version>.sif
```

Open http://localhost:8080 in your browser. The password is printed to the terminal.

## Building the image locally

Requires [Singularity](https://sylabs.io/singularity/) ≥ 3.8.6 or [Apptainer](https://apptainer.org/). For your test environment, Singularity 3.8.6 via conda is also acceptable.

The build script tries `--fakeroot` first. If that fails and `sudo` is available, it automatically retries without `--fakeroot`.

```bash
# Build into the repository-local sif directory using the default version from code-server.def
./scripts/build_sif.sh

# Build with a specific code-server version
./scripts/build_sif.sh 4.117.0
```

## Testing a built image

This repository includes a smoke test that validates commands from the built image:

- `code-server --help`
- `code-server --version`

```bash
# Test the latest image under sif/
./scripts/test_sif.sh

# Test an explicit image path
./scripts/test_sif.sh ./sif/code-server_4.117.0.sif
```

## Usage examples

```bash
# Run with default settings (listens on 127.0.0.1:8080)
singularity run code-server.sif

# Listen on all interfaces and disable password authentication
singularity run code-server.sif --bind-addr 0.0.0.0:8080 --auth none

# Bind a local directory and open it as the workspace
singularity run --bind /path/to/project:/workspace code-server.sif /workspace

# Pass through the host network namespace
singularity run --net code-server.sif
```

## Automated builds

The [build workflow](.github/workflows/build.yml) runs every Monday and automatically builds and releases a new image whenever a new code-server version is available.

You can also trigger a manual build from the **Actions** tab, optionally specifying a particular version.
