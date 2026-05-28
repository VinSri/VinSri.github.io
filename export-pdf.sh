#!/usr/bin/env bash
# Export a PDF from index.html using headless Chrome/Chromium.
# Run from this directory after editing the HTML. Requires fonts (loads Google Fonts over network).

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-Vinodhini-Subbu-Resume.pdf}"
OUT_ABS="$DIR/$OUT"
PORT="${PORT:-8799}"
URL="http://127.0.0.1:$PORT/index.html"

CHROME=""
for c in google-chrome-stable google-chrome chromium chromium-browser; do
  if command -v "$c" &>/dev/null; then
    CHROME="$c"
    break
  fi
done

if [[ -z "$CHROME" ]]; then
  echo "No Chrome/Chromium found. Install google-chrome-stable or chromium, or use the site button:"
  echo "  open index.html → Save as PDF — Print dialog → Destination: Save as PDF"
  exit 1
fi

cleanup() {
  kill "$HTTP_PID" 2>/dev/null || true
}
trap cleanup EXIT

python3 -m http.server "$PORT" --directory "$DIR" >/dev/null 2>&1 &
HTTP_PID=$!
sleep 0.4

# --run-all-compositor-stages-before-draw helps fonts/layout settle
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --run-all-compositor-stages-before-draw \
  --print-to-pdf="$OUT_ABS" \
  "$URL"

echo "Wrote $OUT_ABS"
