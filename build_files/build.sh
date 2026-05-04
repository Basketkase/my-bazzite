#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# remove kde plasma
dnf5 remove -y \
    plasma-workspace \
    plasma-*    \
    kde-*       \
    kf6-*       \
    kwin*       \
    breeze*

dnf5 autoremove -y

dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable avengemedia/danklinux

# Niri and DMS install with dependencies
dnf5 -y install						\
		niri						\
		dms							\
		xwayland-satellite			\
		xdg-desktop-portal-gnome	\
		greetd						\
		dms-greeter

# My software
dnf5 -y install						\
		kitty						\
		nautilus					\
		blueman						\
		pavucontrol					\
		papirus-icon-theme

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux

# Configure greetd with DankGreeter
install -Dm644 /dev/stdin /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
user = "greetd"
command = "dms-greeter --command niri-session"
EOF

# Set Papirus as default icon theme for GTK apps
install -Dm644 /dev/stdin /etc/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus
EOF

install -Dm644 /dev/stdin /etc/gtk-4.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus
EOF

systemctl enable greetd
systemctl enable podman.socket

install -Dm644 /ctx/ssh-agent-env.conf /etc/skel/.config/environment.d/ssh-agent.conf

systemctl --global add-wants graphical-session.target dms
systemctl --global add-wants graphical-session.target ssh-agent.service
