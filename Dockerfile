# code-server (linuxserver.io) + de tools voor T-Tool die een image-update moeten overleven.
# Het basisimage bouwt als root; de container draait daarna als abc (PUID/PGID).
FROM lscr.io/linuxserver/code-server:latest

# Claude Code (native) werkt zichzelf bij in ~/.local (op het /config-volume); de link
# ~/.local/bin/claude wijst steeds naar de nieuwste versie. Zo is "claude" overal te vinden.
ENV PATH="${PATH}:/config/.local/bin"

# svn en svnadmin (testrepository), gh (testflow en releases), less en script (schermtests),
# pandoc (de HTML-versie van de documentatie)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv subversion gh less util-linux pandoc \
 && rm -rf /var/lib/apt/lists/*

# Testharnas van T-Tool in de systeem-Python, zodat 'bash tests/run_all.sh' meteen werkt
RUN pip install --break-system-packages --no-cache-dir pyte vermin flake8 coverage

# Node.js 24 LTS voor de website van OBD Chotkan (Next.js), uit de NodeSource-repository.
# Eerst downloaden: mislukt curl in een pipe, dan zou apt stil de oude nodejs van Ubuntu nemen.
RUN curl -fsSL -o /tmp/nodesource_setup.sh https://deb.nodesource.com/setup_24.x \
 && bash /tmp/nodesource_setup.sh \
 && apt-get install -y --no-install-recommends nodejs \
 && node --version | grep -q '^v24\.' \
 && rm -rf /var/lib/apt/lists/* /tmp/nodesource_setup.sh

# Systeembibliotheken voor Playwright met Chromium (screenshots van de website). De browser
# zelf ('npx playwright install chromium') staat in ~/.cache/ms-playwright op /config en
# blijft dus bewaard.
RUN npx -y playwright@1 install-deps chromium \
 && rm -rf /var/lib/apt/lists/* /root/.npm

# Antigravity CLI (agy), de opvolger van de Gemini CLI: Gemini met het Google AI Pro-abonnement.
# Het officiële script controleert de SHA512 van de download. Eén keer inloggen met 'agy';
# de sessie staat in ~/.gemini (op /config, blijft dus bewaard). De wekelijkse build haalt
# een nieuwe versie op (de ingebouwde self-update mag als abc niet in /usr/local/bin schrijven).
# HOME=/root: het basisimage zet HOME=/config, en daar schrijft het script (cache, PATH in .bashrc)
RUN curl -fsSL https://antigravity.google/cli/install.sh | HOME=/root bash -s -- --dir /usr/local/bin \
 && rm -rf /root/.cache/antigravity /root/.gemini

# gemini-review (Python, standaardbibliotheek): Gemini reviewt wijzigingen, de hele code of een
# voorstel (alleen lezen)
COPY --chmod=755 gemini-review /usr/local/bin/gemini-review

# claude-sessies (Python, standaardbibliotheek): eerdere Claude Code-sessies doorzoeken, lezen en
# exporteren; webpagina via code-server op /proxy/8765/ (dienst in /custom-services.d, zie README)
COPY --chmod=755 claude-sessies /usr/local/bin/claude-sessies

# Controle: faalt de build hier, dan ontbreekt er iets
RUN python3 -c 'import pyte, coverage, curses' \
 && svn --version --quiet && svnadmin --version --quiet && gh --version \
 && node --version && npm --version \
 && vermin --version && flake8 --version && pandoc --version | head -1 \
 && HOME=/root agy --version && gemini-review --help > /dev/null \
 && claude-sessies --help > /dev/null \
 && rm -rf /root/.gemini
