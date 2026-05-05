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
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable yalter/niri

# Niri and DMS with dependencies
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
		breeze-cursor-theme

dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable yalter/niri

### Configure

# Greeter user and cache directory
install -Dm644 /dev/stdin /usr/lib/sysusers.d/dms-greeter.conf <<'EOF'
u greeter 767 "DMS Greeter" /var/cache/dms-greeter -
EOF

install -Dm644 /dev/stdin /usr/lib/tmpfiles.d/dms-greeter.conf <<'EOF'
d /var/cache/dms-greeter 0750 greeter greeter -
EOF

# DMS PAM assets (fingerprint auth for lock screen)
cp /usr/share/quickshell/dms/assets/pam/* /usr/lib/pam.d/

# greetd PAM config — use pam_unix directly instead of system-auth to prevent
# fprintd from hijacking the auth conversation when fingerprints are enrolled
install -Dm644 /dev/stdin /etc/pam.d/greetd <<'EOF'
#%PAM-1.0
auth       required    pam_unix.so
-auth      optional    pam_gnome_keyring.so
auth       include     postlogin

account    required    pam_sepermit.so
account    required    pam_nologin.so
account    include     system-auth

password   include     system-auth

session    required    pam_selinux.so close
session    required    pam_loginuid.so
session    required    pam_selinux.so open
session    optional    pam_keyinit.so force revoke
session    required    pam_namespace.so
session    include     system-auth
-session   optional    pam_gnome_keyring.so auto_start
session    include     postlogin
EOF

# greetd
install -Dm644 /dev/stdin /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri-session"
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

# System services
systemctl enable greetd
systemctl enable podman.socket

# User session defaults
install -Dm644 /ctx/ssh-agent-env.conf /etc/skel/.config/environment.d/ssh-agent.conf
install -Dm755 /ctx/first-run.sh /usr/bin/my-bazzite-first-run
install -Dm755 /ctx/setup.sh /usr/bin/my-bazzite-setup
install -Dm644 /dev/null /etc/skel/.config/my-bazzite-setup-pending

systemctl --global add-wants graphical-session.target dms
systemctl --global add-wants graphical-session.target ssh-agent.service
systemctl --global enable my-bazzite-first-run.service
