# code-server (linuxserver.io) + de tools voor T-Tool die een image-update moeten overleven.
# Het basisimage bouwt als root; de container draait daarna als abc (PUID/PGID).
FROM lscr.io/linuxserver/code-server:latest

# svn en svnadmin (testrepository), gh (testflow en releases), less en script (schermtests),
# pandoc (de HTML-versie van de documentatie)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv subversion gh less util-linux pandoc \
 && rm -rf /var/lib/apt/lists/*

# Testharnas van T-Tool in de systeem-Python, zodat 'bash tests/run_all.sh' meteen werkt
RUN pip install --break-system-packages --no-cache-dir pyte vermin flake8 coverage

# Controle: faalt de build hier, dan ontbreekt er iets
RUN python3 -c 'import pyte, coverage, curses' \
 && svn --version --quiet && svnadmin --version --quiet && gh --version \
 && vermin --version && flake8 --version && pandoc --version | head -1
