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

rm -f /usr/share/wayland-sessions/plasma-steamos-wayland-oneshot.desktop

### Install Packages

dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable yalter/niri

# Niri and DMS with dependencies
dnf5 -y install						\
		niri						\
		dms							\
		xwayland-satellite			\
		xdg-desktop-portal-gnome	\
		gdm							\
		cups-pk-helper				\
		python3-mutagen				\
		cava						\
		matugen						\
		kf6-kimageformats

# My software
dnf5 -y install						\
		kitty						\
		nautilus					\
		blueman						\
		pavucontrol					\
		papirus-icon-theme			\
		breeze-cursor-theme

dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable yalter/niri

### Configure

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

# System services
systemctl enable gdm
systemctl enable podman.socket

# User session defaults
install -Dm644 /ctx/ssh-agent-env.conf /etc/skel/.config/environment.d/ssh-agent.conf

systemctl --global add-wants graphical-session.target dms
systemctl --global add-wants graphical-session.target ssh-agent.service
