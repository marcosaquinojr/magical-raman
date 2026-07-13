#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="sakuraos"
iso_label="SAKURAOS_$(date +%Y%m)"
iso_publisher="SakuraOS Project"
iso_application="SakuraOS Live/Installation Media"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.grub.esp' 'uefi-x86_64.grub.esp' 'uefi-ia32.grub.eltorito' 'uefi-x86_64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"

file_modes=(
  ["/etc/shadow"]="0:0:0400"
  ["/etc/gshadow"]="0:0:0400"
  ["/etc/sudoers.d"]="0:0:0750"
  ["/root"]="0:0:0750"
  ["/root/.automated_script.sh"]="0:0:0755"
  ["/root/.gnupg"]="0:0:0700"
  ["/usr/local/bin/sakura-setup.sh"]="0:0:0755"
)
