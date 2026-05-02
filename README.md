# code-server-singularity

Singularity/Apptainer container image definition for [code-server](https://github.com/coder/code-server) — VS Code in the browser.

## Quick start

Download the latest `.sif` image from the [Releases](https://github.com/Tasu/code-server-singularity/releases) page, then run:

```bash
singularity run code-server_<version>.sif
```

Open http://localhost:8080 in your browser. The password is printed to the terminal.

## Building the image locally

Requires [Apptainer](https://apptainer.org/) (or Singularity ≥ 3.9).

```bash
# Build with the default version bundled in the definition file
singularity build code-server.sif code-server.def

# Build with a specific code-server version
singularity build --build-arg VERSION=4.117.0 code-server.sif code-server.def
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