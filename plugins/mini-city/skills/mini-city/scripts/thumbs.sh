#!/usr/bin/env bash
# Render day/night tile thumbnails for the home page: $SITE/thumbs/<slug>-0.webp and -1.webp (960x640).
#   thumbs.sh <slug> [t=47.5]
set -eu
SITE=${SITE:-$PWD}
# Finds Playwright Chromium (`npx playwright install chromium`), a system Chromium/Chrome, or set CHROME=/path/to/chrome.
# chromium-1234 preferred: newer builds (1255) hang when console logging is on
CHROME=${CHROME:-$( { ls -d ~/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome; ls -d ~/.cache/ms-playwright/chromium-*/chrome-linux64/chrome | sort -V -r; command -v chromium chromium-browser google-chrome google-chrome-stable;
  ls -d "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "/Applications/Chromium.app/Contents/MacOS/Chromium"; } 2>/dev/null | head -1)}
[ -x "$CHROME" ] || { echo "chromium not found; set CHROME=" >&2; exit 1; }
slug=${1:?slug}; t=${2:-47.5}
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
mkdir -p "$SITE/thumbs"
for n in 0 1; do
  timeout 90 "$CHROME" --headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size=1200,800 --virtual-time-budget=4000 \
    --screenshot="$W/$n.png" "file://$SITE/$slug/index.html?t=$t&night=$n&bare=1" 2>/dev/null
  cat > "$W/conv.html" <<HTML
<body><script>const i=new Image();i.onload=()=>{const c=document.createElement('canvas');c.width=960;c.height=640;
c.getContext('2d').drawImage(i,0,0,960,640);const p=document.createElement('pre');p.textContent='\nX='+c.toDataURL('image/webp',.82)+'\n';document.body.appendChild(p)};i.src='$n.png';</script></body>
HTML
  timeout 90 "$CHROME" --headless=new --no-sandbox --disable-gpu --allow-file-access-from-files --virtual-time-budget=5000 --dump-dom "file://$W/conv.html" 2>/dev/null > "$W/dump.html"
  python3 -c "import re,sys,base64;b=re.search(r'X=data:image/webp;base64,([A-Za-z0-9+/=]+)',open(sys.argv[1]).read()).group(1);open(sys.argv[2],'wb').write(base64.b64decode(b))" "$W/dump.html" "$SITE/thumbs/$slug-$n.webp"
  ls -la "$SITE/thumbs/$slug-$n.webp"
done
