# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A bootc container image customization template for building a personalized Linux distribution based on [Bazzite](https://bazzite.gg/) (Universal Blue). Customizations are applied via a Bash build script run inside a container, and the result is published as an OCI image to GHCR, which can then be installed directly or converted to bootable disk images.

## Common Commands

All local development uses [Just](https://just.systems/). Run `just` with no args to list all recipes.

```bash
just build            # Build the OCI container image locally with Podman
just build-qcow2      # Build a QCOW2 VM disk image from the container
just build-iso        # Build an ISO installer
just run-vm-qcow2     # Launch the built QCOW2 image in QEMU (web VNC on port 8006)
just spawn-vm         # Launch with systemd-vmspawn
just lint             # Run shellcheck on all .sh files
just format           # Run shfmt to format Bash scripts
just clean            # Remove all build artifacts
```

## Architecture

### Two-Stage Pipeline

1. **Container image** (`Containerfile` + `build_files/build.sh`): Starts FROM a Bazzite base image, runs `build.sh` to install packages and configure the system, then runs `bootc` lint. The result is an OCI image pushed to GHCR.

2. **Disk image** (optional, via `build-disk.yml`): Converts the OCI image to bootable formats (QCOW2/ISO/RAW) using `bootc-image-builder`. Disk layouts are defined in `disk_config/`.

### Key Files

- **`Containerfile`** — Defines the base image (currently `ghcr.io/ublue-os/bazzite:stable`) and invokes `build.sh`.
- **`build_files/build.sh`** — The main customization script. Add `dnf5 install` calls here for packages, `systemctl enable` for services.
- **`Justfile`** — All local build, run, lint, and format recipes.
- **`.github/workflows/build.yml`** — CI: builds and pushes the OCI image on push to `main`, PRs, daily schedule, and manual dispatch. Signs with Cosign.
- **`.github/workflows/build-disk.yml`** — Optional CI: builds bootable disk images for amd64/arm64; can upload to S3.
- **`disk_config/`** — TOML configs for QCOW2 (VMs), GNOME ISO, and KDE ISO installers.

### CI/CD Notes

- Images are signed with Cosign. The `SIGNING_SECRET` must be set in GitHub Actions secrets (generate with `cosign generate-key-pair`).
- Renovate and Dependabot automate dependency updates; Renovate auto-merges pin/digest updates.
- Published image tags include `latest`, `latest.YYYYMMDD`, and `sha-<commit>`.
