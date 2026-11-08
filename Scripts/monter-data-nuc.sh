#!/usr/bin/env bash
set -euo pipefail

# Sjekk at scriptet kjøres med sudo / som root
if [ "$EUID" -ne 0 ]; then
    echo "Dette scriptet må kjøres med sudo / som root." >&2
    exit 1
fi

TARGET_USER="archruud"
TARGET_DIR="/home/${TARGET_USER}/Data"
DISK_UUID="249e98d9-1aa6-4041-b537-572b22093b4d"
FSTAB_LINE="UUID=${DISK_UUID} ${TARGET_DIR} ext4 defaults,noatime,nofail 0 2"

# 1. Avmonter dersom filbehandleren har automontert disken
if grep -q "${DISK_UUID}" /proc/mounts; then
    echo "==> Avmonterer eksisterende midlertidig mount..."
    umount "/dev/disk/by-uuid/${DISK_UUID}" || true
fi

# 2. Opprett monteringsmappe i hjemmemappen
echo "==> Oppretter mappen ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}"

# 3. Legg til i /etc/fstab dersom den ikke allerede finnes der
if grep -q "${DISK_UUID}" /etc/fstab; then
    echo "==> UUID finnes allerede i /etc/fstab."
else
    echo "==> Legger inn montering i /etc/fstab..."
    echo "${FSTAB_LINE}" >> /etc/fstab
fi

# 4. Monter alle disker definert i fstab
echo "==> Mounter ${TARGET_DIR} via fstab..."
systemctl daemon-reload
mount "${TARGET_DIR}"

# 5. Sett eierskap og fulle rettigheter for archruud
echo "==> Setter eierskap og rettigheter..."
chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_DIR}"
chmod 755 "${TARGET_DIR}"

echo "==> Ferdig! 2TB-disken er nå fast montert på ${TARGET_DIR} med full tilgang for ${TARGET_USER}."
