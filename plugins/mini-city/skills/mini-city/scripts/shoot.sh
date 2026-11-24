#!/usr/bin/env bash
# Screenshot a mini-city page and report console errors.
#   shoot.sh <slug> [t ...]      day frames at each t, night frames at 3 of them + 48, phone at 47.5
#   shoot.sh home                home page, desktop + phone
# Env: SITE (default: current dir, the repo root), OUT (default /tmp/mini-city-shots/<slug>), CHROME
set -u
SITE=${SITE:-$PWD}
# Finds Playwright Chromium (`npx playwright install chromium`), a system Chromium/Chrome, or set CHROME=/path/to/chrome.
# chromium-1234 preferred: newer builds (1255) hang when console logging is on
CHROME=${CHROME:-$( { ls -d ~/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome; ls -d ~/.cache/ms-playwright/chromium-*/chrome-linux64/chrome | sort -V -r; command -v chromium chromium-browser google-chrome google-chrome-stable;
  ls -d "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "/Applications/Chromium.app/Contents/MacOS/Chromium"; } 2>/dev/null | head -1)}
[ -x "$CHROME" ] || { echo "chromium not found; set CHROME=" >&2; exit 1; }
slug=${1:?slug}; shift
OUT=${OUT:-${TMPDIR:-/tmp}/mini-city-shots/$slug}; mkdir -p "$OUT"
ERR=0; NOLOG=0
shot(){ # name w h url
  local args=(--headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size=$2,$3 --virtual-time-budget=4000
    --allow-file-access-from-files --screenshot="$OUT/$1.png" "$4")
  local log
  if log=$(timeout 45 "$CHROME" --enable-logging=stderr --v=0 "${args[@]}" 2>&1 </dev/null); then
    local e; e=$(grep -E "Uncaught|CONSOLE.*(Error|error)" <<<"$log" | head -5)
    if [ -n "$e" ]; then echo "ERRORS in $1:"; echo "$e"; ERR=1; fi
  else
    timeout 90 "$CHROME" "${args[@]}" >/dev/null 2>&1 </dev/null
    echo "($1: console check skipped, logging run timed out)"; NOLOG=1
  fi
  echo "$OUT/$1.png"
}
if [ "$slug" = home ]; then
  shot home 1280 900 "file://$SITE/index.html"
  shot home-phone 390 844 "file://$SITE/index.html"
else
  F="$SITE/$slug/index.html"; [ -f "$F" ] || { echo "missing $F" >&2; exit 1; }
  # syntax check of the inline script
  if command -v node >/dev/null; then
    python3 -c "import re,sys;s=open(sys.argv[1]).read();print('\n'.join(re.findall(r'<script>(.*?)</script>',s,re.S)))" "$F" > "$OUT/_page.js"
    node --check "$OUT/_page.js" 2>&1 | head -5 && echo "syntax ok"
  fi
  TS=("$@"); [ ${#TS[@]} -eq 0 ] && TS=(3 8 14 20 26 32 38 44 48)
  for t in "${TS[@]}"; do shot "day-$t" 1440 900 "file://$F?t=$t&night=0"; done
  n=${#TS[@]}; for t in $(printf '%s\n' "${TS[$((n/4))]}" "${TS[$((n/2))]}" "${TS[$((3*n/4))]}" 48 | awk '!s[$0]++'); do shot "night-$t" 1440 900 "file://$F?t=$t&night=1"; done
  shot "phone-47.5" 390 844 "file://$F?t=47.5&night=0"
fi
[ $ERR = 0 ] && [ $NOLOG = 0 ] && echo "no console errors"; exit $ERR
