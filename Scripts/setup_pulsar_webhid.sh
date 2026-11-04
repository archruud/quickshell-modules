#!/usr/bin/env bash

# Avslutt umiddelbart hvis en kommando feiler
set -e

RULE_FILE="/etc/udev/rules.d/50-pulsar-webhid.rules"

echo "=== Konfigurerer udev-regel for Pulsar WebHID ==="

# 1. Opprett regelfilen med riktig innhold ved hjelp av sudo og tee
echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess"' | sudo tee "$RULE_FILE" > /dev/null

echo "✔ Regel opprettet i $RULE_FILE"

# 2. Last inn udev-reglene på nytt
echo "=== Laster inn udev-regler på nytt ==="
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "✔ Udev-regler oppdatert!"
echo "🎉 Alt er klart! Start nettleseren din på nytt og koble til tastaturet."
