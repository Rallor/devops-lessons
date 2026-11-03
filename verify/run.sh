#!/usr/bin/env bash
# Запуск усіх перевірок етапу: ./verify/run.sh 1
set -uo pipefail
cd "$(dirname "$0")/.."

STAGE="${1:-1}"
DIR="verify/stage-${STAGE}"
[[ -d "$DIR" ]] || { echo "Немає каталогу $DIR"; exit 2; }

[[ -f lab.env ]] && set -a && . ./lab.env && set +a

export REPORT="verify-report.md"
{
  echo "# Звіт перевірок — етап ${STAGE}"
  echo
  echo "- Дата: $(date -u '+%Y-%m-%d %H:%M UTC')"
  echo "- Стенд: ${LAB_DOMAIN:-${LAB_HOST:-?}}"
  echo
} > "$REPORT"

rc=0
for f in "$DIR"/*.sh; do
  [[ -e "$f" ]] || continue
  name="$(basename "$f")"
  echo "== $name"
  echo "" >> "$REPORT"; echo "## $name" >> "$REPORT"; echo "" >> "$REPORT"
  bash "$f" || rc=1
done

echo
echo "Звіт: $REPORT"
echo "Ручні пункти, які скрипт не перевіряє: $DIR/manual.md"
exit "$rc"
