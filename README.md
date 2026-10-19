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
script `gemini-review` (Python, alleen de standaardbibliotheek). Daarmee laat Claude Code
Gemini code reviewen of een voorstel beoordelen, op het Google AI Pro-abonnement (geen
API-key nodig).

- Eén keer inloggen: start `agy` in een terminal, open de getoonde URL, log in met het
  Google-account met Google AI Pro en plak de code terug. De sessie staat in `~/.gemini`
  (op `/config`) en blijft dus bewaard bij een nieuw image.
- **Alleen lezen.** Gemini krijgt alle code in de prompt en draait in plan-modus (niet
  samen met `--disable-slash-commands`, want dan doet plan-modus niets). Voor het geval
  Gemini toch een opdracht wil uitvoeren, staan in `~/.gemini/antigravity-cli/settings.json`
  alleen leesopdrachten toegestaan; in print-modus wordt al het andere geweigerd:

  ```json
  "permissions": { "allow": [ "read_file(/ai/workspace)", "command(git diff)",
    "command(git log)", "command(git show)", "command(git status)", "command(git ls-files)",
    "command(git grep)", "command(git blame)", "command(cat)", "command(head)",
    "command(tail)", "command(ls)", "command(grep)", "command(wc)", "command(nl)",
    "command(sed -n)" ] }
  ```

| Opdracht | Wat |
| --- | --- |
| `gemini-review` | de niet-gecommitte wijzigingen, ook nieuwe bestanden |
| `gemini-review main...HEAD -- src tests` | een ander bereik (alle `git diff`-argumenten) |
| `gemini-review --alles` | de hele codebase, in delen van ~110 KB, plus een ronde over de samenhang tussen modules |
| `gemini-review --advies voorstel.md [bestanden]` | een second opinion op een voorstel, met de genoemde bestanden en een kaart van de hele codebase als context; Gemini mag losse bestanden lezen |
| `gemini-review --samenvoegen Gemini=a.json Claude=b.json` | bevindingen uit meer bronnen samenvoegen tot één rapport; dubbele punten worden herkend (zelfde bestand, regels dicht bij elkaar) en krijgen alle bronnen en de hoogste ernst |
| `--droog` | toont de aanroepen en hun grootte, zonder iets te versturen |
| `--opnieuw` | de cache niet gebruiken; `--parallel N` (standaard 2) |

- **Rapport** in `.git/gemini-review/<tijd>-<soort>/`: `rapport.md` (gesorteerd op ernst,
  met `bestand:regel`, soort en voorstel), `bevindingen.json` en per aanroep de ruwe JSON.
  Gemini antwoordt in een vast JSON-schema, zodat het samenvoegen betrouwbaar is.
- **Zuinig met tokens.** Elke aanroep kost ~13.000 tokens vaste overhead, dus zo groot
  mogelijke delen (de grens is één argument van 128 KB); volledige bestanden met
  regelnummers in plaats van een diff tegen een lege boom; geen tools; hooguit 15
  bevindingen per deel. Bij `--alles` gaan alleen de bestanden mee die sinds de vorige
  keer veranderd zijn; de bevindingen van de andere komen uit de cache per bestand
  (`.git/gemini-review/cache/bestanden`; de sleutel bevat het pad, de inhoud, het model en
  de prompt). Na één gewijzigd bestand kost een volledige review dus één aanroep plus de
  samenhangronde.
- **Per repository** een bestand `.gemini-review` met de paden voor `--alles`, een korte
  beschrijving van het project (gaat mee in elke aanroep: kort houden) en het bestand met de
  afspraken (gaat mee in de samenhangronde en bij `--advies`; meer bestanden mag, gescheiden
  door spaties, bijvoorbeeld een `CLAUDE.md` per submap):

  ```ini
  [review]
  paden = src tests scripts
  context = Korte beschrijving en de belangrijkste regels van het project.
  afspraken = CLAUDE.md
  ```
- **Model:** standaard `gemini-3.8-flash-high`; een ander met `GEMINI_REVIEW_MODEL=<slug>`
  (lijst: `agy models`). Welke modellen er zijn, bepaalt de server per abonnement: met
  Google AI Pro horen daar ook Gemini 4 Argon en Claude 5.5 bij. Staan die er niet, dan ziet
  de CLI het account niet als AI Pro.
- **Geen GitHub-toegang nodig.** Gemini leest de werkmap zelf (altijd actueel, ook
  niet-gecommitte wijzigingen). Via GitHub lezen zou geen tokens besparen: alles wat Gemini
  leest telt mee, en zelf lezen is duurder dan meegeven in de prompt.
- **Te lang antwoord** ("output token limit"): de tweede poging vraagt om hooguit 8 punten.
- **Exitcodes:** 0 gelukt, 1 een deel mislukt (staat in het rapport), 2 verkeerde aanroep,
  3 niet ingelogd of quotum op (stopt meteen, ook de lopende aanroepen).
- Quotum bekijken: `agy -p "/usage"`.
