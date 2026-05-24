#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Install PaperWM GNOME extension system-wide
PAPERWM_ZIP=$(curl -s https://api.github.com/repos/paperwm/PaperWM/releases/latest | grep -m1 '"zipball_url"' | sed 's/.*"zipball_url": "\(.*\)".*/\1/')
curl -L "${PAPERWM_ZIP}" -o /tmp/paperwm.zip
unzip /tmp/paperwm.zip -d /tmp/paperwm-extract
PAPERWM_DIR=$(find /tmp/paperwm-extract -maxdepth 1 -mindepth 1 -type d | head -1)
mkdir -p /usr/share/gnome-shell/extensions/paperwm@paperwm.github.com
cp -r "${PAPERWM_DIR}"/. /usr/share/gnome-shell/extensions/paperwm@paperwm.github.com/
rm -rf /tmp/paperwm.zip /tmp/paperwm-extract

# YADM for dotfile management
curl -fLo /usr/bin/yadm https://github.com/yadm-dev/yadm/raw/master/yadm && chmod a+x /usr/bin/yadm

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

# Default shell
useradd -D -s /usr/bin/fish