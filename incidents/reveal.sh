#!/usr/bin/env bash
# Показує розбір останнього інциденту і рахує час відновлення.
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -f .incident-state ]] || { echo "Активного інциденту немає."; exit 1; }
read -r ID START < .incident-state
NOW=$(date -u +%s); MIN=$(( (NOW - START) / 60 ))

echo "Інцидент: $ID"
echo "Час від запуску: ${MIN} хв"
echo
read -r -p "Сервіс уже відновлено і verify зелений? [y/N] " a
[[ "$a" =~ ^[Yy]$ ]] || { echo "Тоді ще рано. Повертайся до prompts/05-incident-master.md."; exit 0; }

echo
echo "=== Розбір ==="
for d in incidents/stage-*/"$ID".b64; do
  [[ -e "$d" ]] && base64 -d < "$d" | sed -n 's/^#SOLUTION: //p'
done
cat <<'MSG'

=== Далі ===
1. Напиши постмортем: templates/postmortem.md
2. Віддай на ревʼю: prompts/06-postmortem-review.md
3. Запиши свій час відновлення в progress.md — це твоя метрика, вона має падати.
MSG
rm -f .incident-state
