# code-server-custom

`lscr.io/linuxserver/code-server:latest` plus de tools om T-Tool lokaal te testen en
uit te brengen: python3 (pip, venv), subversion, gh, less, pandoc en in de
systeem-Python pyte, vermin, flake8 en coverage (dekkingsmeting van de T-Tool-testflow).
GitHub Actions bouwt het image bij elke push en elke maandag (dan komt een nieuwe
code-server-versie mee) en zet het op `ghcr.io/rakeshchotkan/code-server-custom:latest`.

Portainer: zet `image: ghcr.io/rakeshchotkan/code-server-custom:latest` en werk de stack
bij met "Re-pull image" aan. Zet `PUID`/`PGID` op de eigenaar van de gekoppelde mappen.

## Gemini (Antigravity CLI)

Het image bevat ook de Antigravity CLI (`agy`), de opvolger van de Gemini CLI, en het
script `gemini-review`. Daarmee kan Claude Code de niet-gecommitte wijzigingen door
Gemini laten reviewen, op het Google AI Pro-abonnement (geen API-key nodig).

- Eén keer inloggen: start `agy` in een terminal, open de getoonde URL, log in met het
  Google-account met Google AI Pro en plak de code terug. De sessie staat in `~/.gemini`
  (op `/config`) en blijft dus bewaard bij een nieuw image.
- `gemini-review` (in een git-repository): stuurt de diff sinds HEAD, inclusief nieuwe
  bestanden, naar Gemini in plan-modus; Gemini past niets aan. Ander bereik:
  `gemini-review --cached` of `gemini-review main...HEAD`. Ander model:
  `GEMINI_REVIEW_MODEL=<slug>` (lijst: `agy models`).
- Quotum bekijken: `agy -p "/usage"`.
