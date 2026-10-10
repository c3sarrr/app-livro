#!/usr/bin/env bash
# T02 — ambiente de medição no WSL (Ubuntu 24.04), o mesmo da G01: Node 22, Playwright 1.56 (Chromium 141) e as
# bibliotecas Python da medição e das fontes num venv. Tudo em /opt/booknest-medicao (o wsl.sh liga esse ambiente).
# Rodar uma vez, como root no WSL:  wsl -u root bash tools/medicao/ambiente_wsl.sh
set -euo pipefail
B=/opt/booknest-medicao
mkdir -p "$B" && cd "$B"
if [ ! -x "$B/node/bin/node" ]; then
  curl -fsSLO https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt
  NAME=$(grep -o 'node-v22[^ ]*-linux-x64.tar.xz' SHASUMS256.txt | head -1)
  curl -fsSLO "https://nodejs.org/dist/latest-v22.x/$NAME"
  grep " $NAME\$" SHASUMS256.txt | sha256sum -c -
  tar -xJf "$NAME"
  ln -sfn "$B/${NAME%.tar.xz}" "$B/node"
fi
export PATH="$B/node/bin:$PATH"
node -v
[ -f package.json ] || npm init -y >/dev/null
npm install --no-fund --no-audit playwright@1.56.1
node -e "const b=JSON.parse(require('fs').readFileSync('node_modules/playwright-core/browsers.json','utf8')).browsers.find(x=>x.name==='chromium'); console.log('chromium', b.revision, b.browserVersion)"
npx playwright install --with-deps chromium
apt-get install -y python3-venv fonts-inter >/dev/null
[ -d "$B/venv" ] || python3 -m venv "$B/venv"
"$B/venv/bin/pip" install --quiet pillow numpy fonttools brotli uharfbuzz
"$B/venv/bin/python" -c "import sys, PIL, numpy, fontTools, brotli, uharfbuzz; print('python', sys.version.split()[0], 'Pillow', PIL.__version__, 'numpy', numpy.__version__, 'fontTools', fontTools.version, 'uharfbuzz', uharfbuzz.__version__)"
# fontconfig do usuário que mede (rode também como esse usuário, se não for o root):
# - a reserva sans-serif é a Inter (como no contêiner da G01: o "≈" das 20 e 26b não está na Figtree do arquivo);
# - suavização em tons de cinza: o Ubuntu do WSL liga o subpixel (10-sub-pixel-rgb.conf) e o texto pequeno a 1x/2x sai
#   com franjas coloridas (as prévias do arquivo e o contêiner da G01 não têm) — também no supersample 10×, nos textos
#   minúsculos (os ~1,5 px dos `<text>` da capa da mini-barra da 01b viram ~15 px);
# - sem hinting: o Ubuntu liga o hintslight (10-hinting-slight.conf). As fontes do arquivo não sentem (o Chromium roda
#   com --font-render-hinting=none), mas as do sistema sim: o "≈" das 20 e 26b (Inter Bold) saía 0,012 px mais baixo
#   (86 e 90 px a @3x, ≤ 15/255). Sem hinting a G01 sai igual byte a byte (305 de 305 arquivos) e o A2 passa nas 13.
mkdir -p ~/.config/fontconfig
cat > ~/.config/fontconfig/fonts.conf <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias><family>sans-serif</family><prefer><family>Inter</family></prefer></alias>
  <match target="font">
    <edit name="rgba" mode="assign"><const>none</const></edit>
    <edit name="lcdfilter" mode="assign"><const>lcdnone</const></edit>
    <edit name="hinting" mode="assign"><bool>false</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintnone</const></edit>
  </match>
</fontconfig>
XML
fc-cache -f >/dev/null
echo PRONTO
