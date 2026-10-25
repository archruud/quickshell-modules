# 02 – Viktige fixes

Denne delen gjør de tre gamle fixene rene og legger til to grunnfunksjoner som har
vært problematiske i Hyprland-sessionen.

## Gjør dette

1. Dolphin bruker Kitty som ekstern terminal.
2. Oppretter/oppdaterer XDG-brukermapper med norsk locale.
3. Setter standardprogrammer via XDG MIME.
4. Installerer `hyprland-base.lua`.
5. Sikrer at `hyprpolkitagent` kjører.

## Ekstra NVMe

Vi legger **ikke** den ekstra disken i `/etc/fstab` bare for å kunne klikke på den i
Dolphin. `udisks2` + en fungerende polkit-agent skal gi korrekt autorisasjonsdialog
ved behov.

## Passord / shares

`01-base` installerer `gnome-keyring` + `libsecret`. Dette gir Secret Service-backend
for programmer som kan lagre credentials. Dolphin/KIO får `kio-extras`, `kio-fuse`
og SMB-klientstøtte.

Hvis et bestemt NAS-share fortsatt ikke lagrer passord etter ny innlogging, tester vi
det konkrete sharet før vi eventuelt velger permanent CIFS-mount.
