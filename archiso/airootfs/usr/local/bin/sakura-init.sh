#!/usr/bin/env bash
# sakura-init.sh - Runs on first boot of the Live ISO to configure dconf and desktop managers.

set -euo pipefail

# Compile dconf system databases
if [ -d /etc/dconf/db/local.d ]; then
    dconf update
fi

# Ensure GDM (GNOME Display Manager) is enabled for graphical login
systemctl enable gdm.service || true

# Ensure NetworkManager is enabled for internet access
systemctl enable NetworkManager.service || true
