#!/bin/bash
[[ -f "${HOME}/.config/my-bazzite-setup-pending" ]] || exit 0
kitty --title "First Boot Setup" /usr/local/bin/my-bazzite-setup
