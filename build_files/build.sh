#!/bin/bash

set -ouex pipefail

### Remove KDE/Plasma

dnf5 remove -y \
    plasma-workspace \
    plasma-*    \
    kde-*       \
    kwin*       \
    breeze*

dnf5 autoremove -y

### Install Packages

dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable yalter/niri
dnf5 -y copr enable solopasha/hyprland

# Niri and DMS with dependencies
dnf5 -y install						\
		sddm						\
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

# Desktop support software
dnf5 -y install						\
		papirus-icon-theme			\
		breeze-cursor-theme			\
		hyprlock					\
		swayidle					\
		gvfs-mtp					\
		gvfs-gphoto2				\
		gvfs-smb					\
		gvfs-fuse					\
		gvfs-archive				\
		tumbler						\
		file-roller

# My software
dnf5 -y install						\
		kitty						\
		fuzzel						\
		nautilus					\
		pavucontrol


dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable yalter/niri
dnf5 -y copr disable solopasha/hyprland

# Disable terra-mesa repo: its gpgkey uses a file:// path that bootc-image-builder
# can't resolve when building ISO/disk images. Packages are already in the image.
sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/terra-mesa.repo

### Configure

# Remove extra desktop files
rm -f /usr/share/wayland-sessions/plasma-steamos-wayland-oneshot.desktop
rm -f /usr/share/wayland-sessions/gamescope-session.desktop
rm -f /usr/share/wayland-sessions/gamescope-session-steam.desktop
rm -f /usr/share/wayland-sessions/gnome.desktop
rm -f /usr/share/wayland-sessions/gnome-wayland.desktop

# Remove unused skel configuration
rm -f /etc/skel/.config/kcminputrc

# bootc install configuration
install -Dm644 /dev/stdin /usr/lib/bootc/install/00-default.toml <<'EOF'
[install]
root-fs-type = "btrfs"
EOF

# GTK icon theme
install -Dm644 /dev/stdin /etc/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus
gtk-cursor-theme-name=Breeze
EOF

install -Dm644 /dev/stdin /etc/gtk-4.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus
gtk-cursor-theme-name=Breeze
EOF

# Hyprlock default config
install -Dm644 /ctx/hyprlock.conf /etc/xdg/hypr/hyprlock.conf

# Niri default config
install -Dm644 /ctx/niri-config.kdl /etc/niri/config.kdl

# User systemd services
install -Dm644 /ctx/ssh-agent.service /usr/lib/systemd/user/ssh-agent.service
install -Dm644 /ctx/swayidle.service /usr/lib/systemd/user/swayidle.service

# User session defaults
install -Dm644 /ctx/ssh-agent-env.conf /etc/skel/.config/environment.d/ssh-agent.conf
install -Dm644 /ctx/dms-settings.json /etc/skel/.config/DankMaterialShell/settings.json

# System services
systemctl enable sddm
systemctl enable podman.socket

systemctl --global add-wants niri.service dms
systemctl --global add-wants niri.service swayidle.service
systemctl --global add-wants niri.service ssh-agent.service
