# 01 – Minimal Base

Kjøres etter første boot fra Archinstall.

Archinstall antas allerede å ha installert Hyprland, Dolphin, Kitty, Wayland-portalen,
polkit-grunnpakken og Intel-grafikkdriverne som ble valgt under installasjonen.

Denne delen legger til backendene vi trenger for nettverk, lyd, Bluetooth, secrets,
diskmount, Dolphin/KIO og Quickshell.

`aur-packages.txt` er med vilje tom. `yay` installeres, men vi begynner uten AUR-pakker.
