# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A bootc container image customization template for building a personalized Linux distribution based on [Bazzite](https://bazzite.gg/) (Universal Blue). Customizations are applied via a Bash build script run inside a container, and the result is published as an OCI image to GHCR, which can then be installed directly or converted to bootable disk images.

## Customizations

This image starts from `ghcr.io/ublue-os/bazzite-dx:stable` and makes the following changes:

- **KDE/Plasma removed** — `plasma-workspace`, `plasma-*`, `kde-*`, `kf6-*`, `kwin*`, `breeze*`
- **Niri** — Wayland tiling compositor, launched via `niri-session`
- **DMS (DankMaterialShell)** — Desktop shell, started as a systemd user service on `graphical-session.target`
- **DankGreeter** — greetd-based login greeter from `avengemedia/danklinux` COPR, configured to launch `niri-session`
- **xwayland-satellite** — XWayland support for legacy X11 apps
- **xdg-desktop-portal-gnome** — Desktop portal backend
- **Papirus icon theme** — Set as system default for GTK3 and GTK4 apps via `/etc/gtk-{3,4}.0/settings.ini`
- **Apps** — kitty, nautilus, blueman, pavucontrol
- **podman.socket** — Enabled at boot
- **SSH agent** — Environment config seeded via `/etc/skel`

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

- **`Containerfile`** — Defines the base image (currently `ghcr.io/ublue-os/bazzite-dx:stable`), copies `services/` into `/usr/lib/systemd/user/`, and invokes `build.sh`.
- **`build_files/build.sh`** — The main customization script. Add `dnf5 install` calls here for packages, `systemctl enable` for services.
- **`services/`** — Custom user-level systemd unit files copied directly into the image at `/usr/lib/systemd/user/`.
- **`Justfile`** — All local build, run, lint, and format recipes.
- **`.github/workflows/build.yml`** — CI: builds and pushes the OCI image on push to `main`, PRs, daily schedule, and manual dispatch. Signs with Cosign.
- **`.github/workflows/build-disk.yml`** — Optional CI: builds bootable disk images for amd64/arm64; can upload to S3.
- **`disk_config/`** — TOML configs for QCOW2 (VMs), GNOME ISO, and KDE ISO installers.

## Commit Style

Keep commit messages short — one line, two at most. Always include the Co-Authored-By signature when Claude has made changes:

```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

### CI/CD Notes

- Images are signed with Cosign. The `SIGNING_SECRET` must be set in GitHub Actions secrets (generate with `cosign generate-key-pair`).
- Renovate and Dependabot automate dependency updates; Renovate auto-merges pin/digest updates.
- Published image tags include `latest`, `latest.YYYYMMDD`, and `sha-<commit>`.
