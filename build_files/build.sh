#!/bin/bash

set -ouex pipefail

### Install Packages

dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable yalter/niri

# Niri and DMS with dependencies
dnf5 -y install						\
		niri						\
		xwayland-satellite			\
		xdg-desktop-portal-gnome	\
		dms							\
		cups-pk-helper				\
		cava						\
		matugen						\
		cliphist					\
		dsearch						\
		qt6-qtmultimedia			\
		kf6-kimageformats

# My software
dnf5 -y install						\
		kitty						\
		fuzzel						\
		pavucontrol

dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable yalter/niri

# Disable terra-mesa repo: its gpgkey uses a file:// path that bootc-image-builder
# can't resolve when building ISO/disk images. Packages are already in the image.
sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/terra-mesa.repo


### Configure

# bootc install configuration
install -Dm644 /dev/stdin /usr/lib/bootc/install/00-default.toml <<'EOF'
[install]
root-fs-type = "btrfs"
EOF

# Restrict KDE-only autostart apps from launching in other sessions
echo "OnlyShowIn=KDE;" >> /etc/xdg/autostart/org.kde.xwaylandvideobridge.desktop

# System services
systemctl enable podman.socket

systemctl --global add-wants niri.service dms
