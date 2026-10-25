# 03 – Kitty + Bash

Installerer Kitty-konfigurasjon og brukerens eksisterende Bash-oppsett uten å eie hele
`~/.bashrc`.

`~/.bashrc` får bare en liten source-blokk:

```bash
[ -f "$HOME/.config/bash/archruud.bash" ] && source "$HOME/.config/bash/archruud.bash"
[ -f "$HOME/.config/bash/archruud-local.bash" ] && source "$HOME/.config/bash/archruud-local.bash"
```

Dermed kan prosjektets aliases oppdateres uten å overskrive andre lokale Bash-endringer.
