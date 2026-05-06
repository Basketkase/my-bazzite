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
rm -f /usr/share/wayland-sessions/gamescope-session.desktop
rm -f /usr/share/wayland-sessions/gamescope-session-steam.desktop
rm -f /usr/share/wayland-sessions/gnome.desktop
rm -f /usr/share/wayland-sessions/gnome-wayland.desktop

### Install Packages

dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable yalter/niri
dnf5 -y copr enable solopasha/hyprland

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
		breeze-cursor-theme			\
		hyprlock					\
		swayidle

dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable yalter/niri
dnf5 -y copr disable solopasha/hyprland

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
install -Dm644 /ctx/hyprlock.conf /etc/skel/.config/hypr/hyprlock.conf

systemctl --global add-wants graphical-session.target dms
systemctl --global add-wants graphical-session.target swayidle.service
systemctl --global add-wants graphical-session.target ssh-agent.service
