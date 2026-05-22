#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Programs I want
dnf5 install -y					\
		kitty

# Install Niri/DMS as alternative to gnome
dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable yalter/niri

dnf5 -y install								\
				niri						\
				dms							\
				xwayland-satellite			\
				xdg-desktop-portal-gnome	\
				cava						\
				matugen						\
				cliphist					\
				dsearch


dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable yalter/niri


# Start DMS with Niri
systemctl --global add-wants niri.service dms
