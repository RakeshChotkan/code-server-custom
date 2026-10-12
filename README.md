# code-server-custom

`lscr.io/linuxserver/code-server:latest` plus de tools om T-Tool lokaal te testen en
uit te brengen: python3 (pip, venv), subversion, gh, less en in de systeem-Python
pyte, vermin en flake8.
GitHub Actions bouwt het image bij elke push en elke maandag (dan komt een nieuwe
code-server-versie mee) en zet het op `ghcr.io/rakeshchotkan/code-server-custom:latest`.

Portainer-stack: zet `image: ghcr.io/rakeshchotkan/code-server-custom:latest` en werk
de stack bij met "Re-pull image" aan.

Tip: zet in de stack `PUID=1026` en `PGID=100` (de eigenaar van `/ai/workspace` op de
Synology). Dan kan de gebruiker `abc` in de container in de repo's schrijven, zonder
sudo-trucs.
