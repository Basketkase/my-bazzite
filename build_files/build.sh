#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Install PaperWM GNOME extension system-wide
curl -L "https://github.com/paperwm/PaperWM/releases/latest/download/paperwm@paperwm.github.com.zip" \
    -o /tmp/paperwm.zip
mkdir -p /usr/share/gnome-shell/extensions/paperwm@paperwm.github.com
unzip /tmp/paperwm.zip -d /usr/share/gnome-shell/extensions/paperwm@paperwm.github.com
rm /tmp/paperwm.zip

# Enable extensions system-wide via dconf
mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/00-extensions <<'EOF'
[org/gnome/shell]
enabled-extensions=['logomenu@aryan_k', 'appindicatorsupport@rgcjonas.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'gsconnect@andyholmes.github.io', 'blur-my-shell@aunetx', 'hotedge@jonathan.jdoda.ca', 'caffeine@patapon.info', 'add-to-steam@pupper.space', 'restartto@tiagoporsch.github.io', 'compiz-alike-magic-lamp-effect@hermes83.github.com', 'bazaar-integration@kolunmi.github.io', 'burn-my-windows@schneegans.github.com', 'paperwm@paperwm.github.com']
EOF

if ! grep -q 'system-db:local' /etc/dconf/profile/user 2>/dev/null; then
    mkdir -p /etc/dconf/profile
    printf 'user-db:user\nsystem-db:local\n' > /etc/dconf/profile/user
fi

dconf update

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
