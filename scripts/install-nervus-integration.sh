#!/usr/bin/env bash
set -euo pipefail

NERVUS_DIR="${1:-../nervus-v1}"
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIDGET_SRC="$LAB_DIR/integrations/nervus/widgets/chromebox.py"
WIDGET_DST="$NERVUS_DIR/core/arbor/widgets/chromebox.py"
REGISTRY="$NERVUS_DIR/core/arbor/widgets/__init__.py"

if [ ! -f "$WIDGET_SRC" ]; then
  echo "Missing widget source: $WIDGET_SRC" >&2
  exit 1
fi

if [ ! -f "$REGISTRY" ]; then
  echo "Nervus widget registry not found: $REGISTRY" >&2
  exit 1
fi

cp "$WIDGET_SRC" "$WIDGET_DST"

python3 - "$REGISTRY" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

if "from .chromebox import ChromeboxWidget" not in text:
    marker = "from .calendar import CalendarWidget\n"
    text = text.replace(marker, marker + "from .chromebox import ChromeboxWidget\n")

if "    ChromeboxWidget,\n" not in text:
    marker = "    CalendarWidget,\n"
    text = text.replace(marker, marker + "    ChromeboxWidget,\n")

path.write_text(text)
PY

echo "Installed ChromeboxWidget into $NERVUS_DIR"
echo "Set CHROMEBOX_CTL=$LAB_DIR/scripts/chromeboxctl when running Nervus."
