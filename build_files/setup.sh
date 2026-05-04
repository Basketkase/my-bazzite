#!/bin/bash
echo "Welcome to my-bazzite!"
echo ""
echo "A few one-time setup steps are needed."
echo ""
echo "Step 1: Setting up the DankGreeter login screen..."
dms greeter sync
echo ""
echo "Step 2: Fingerprint enrollment (optional)"
echo "To enroll your fingerprint for login and sudo, run: fprintd-enroll"
echo ""
rm -f "${HOME}/.config/my-bazzite-setup-pending"
echo "Setup complete! This window will not appear again."
read -rp "Press Enter to close..."
