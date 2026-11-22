#!/bin/sh
# Instala o tema SDDM "macchiato", o avatar e a config a partir desta pasta.
# Uso: sudo ~/.config/sddm/install.sh   |   Desfazer: sudo rm /etc/sddm.conf.d/10-theme.conf
set -e
SRC=$(dirname "$(readlink -f "$0")")
install -d /usr/share/sddm/themes/macchiato/assets /usr/share/sddm/faces /etc/sddm.conf.d
install -m644 "$SRC"/macchiato/Main.qml "$SRC"/macchiato/metadata.desktop "$SRC"/macchiato/theme.conf /usr/share/sddm/themes/macchiato/
install -m644 "$SRC"/macchiato/assets/background.jpg /usr/share/sddm/themes/macchiato/assets/
install -m644 "$SRC"/danilo.face.icon /usr/share/sddm/faces/danilo.face.icon
install -m644 "$SRC"/10-theme.conf /etc/sddm.conf.d/10-theme.conf
echo "OK: tema instalado."
