# code-server-custom

`lscr.io/linuxserver/code-server:latest` plus de tools om T-Tool lokaal te testen en
uit te brengen: python3 (pip, venv), subversion, gh, less, pandoc en in de
systeem-Python pyte, vermin, flake8 en coverage (dekkingsmeting van de T-Tool-testflow).
GitHub Actions bouwt het image bij elke push en elke maandag (dan komt een nieuwe
code-server-versie mee) en zet het op `ghcr.io/rakeshchotkan/code-server-custom:latest`.

Portainer: zet `image: ghcr.io/rakeshchotkan/code-server-custom:latest` en werk de stack
bij met "Re-pull image" aan. Zet `PUID`/`PGID` op de eigenaar van de gekoppelde mappen.
