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
    kwin*       \
    breeze*

dnf5 autoremove -y

rm -f /usr/share/wayland-sessions/plasma-steamos-wayland-oneshot.desktop

dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable yalter/niri

# Niri and DMS install with dependencies
dnf5 -y install						\
		niri						\
		dms							\
		xwayland-satellite			\
		xdg-desktop-portal-gnome	\
		greetd						\
		dms-greeter					\
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
		swaylock					\
		swayidle

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable yalter/niri

# Create dedicated greeter user for DankGreeter
install -Dm644 /dev/stdin /usr/lib/sysusers.d/dms-greeter.conf <<'EOF'
u greeter 767 "DMS Greeter" /var/cache/dms-greeter -
EOF

# Create greeter cache directory owned by greeter user
install -Dm644 /dev/stdin /usr/lib/tmpfiles.d/dms-greeter.conf <<'EOF'
d /var/cache/dms-greeter 0750 greeter greeter -
EOF

# Copy DMS PAM assets to fix fingerprint auth at greeter
cp /usr/share/quickshell/dms/assets/pam/* /usr/lib/pam.d/

# Configure greetd with DankGreeter
install -Dm644 /dev/stdin /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
user = "greeter"
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
install -Dm755 /ctx/first-run.sh /usr/bin/my-bazzite-first-run
install -Dm755 /ctx/setup.sh /usr/bin/my-bazzite-setup
install -Dm644 /dev/null /etc/skel/.config/my-bazzite-setup-pending

systemctl --global add-wants graphical-session.target dms
systemctl --global add-wants graphical-session.target swayidle.service
systemctl --global add-wants graphical-session.target ssh-agent.service
systemctl --global enable my-bazzite-first-run.service
