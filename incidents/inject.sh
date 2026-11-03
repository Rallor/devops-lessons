#!/usr/bin/env bash
# Запускає випадковий запечатаний інцидент етапу.
# Використання: ./incidents/inject.sh <етап> [id]
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -f lab.env ]] && set -a && . ./lab.env && set +a
STAGE="${1:-1}"
DIR="incidents/stage-${STAGE}"
[[ -d "$DIR" ]] || { echo "Немає каталогу $DIR"; exit 2; }

if [[ -n "${2:-}" ]]; then
  PICK="$DIR/$2.b64"; [[ -f "$PICK" ]] || { echo "Немає сценарію $2"; exit 2; }
else
  mapfile -t SCENARIOS < <(ls "$DIR"/*.b64 2>/dev/null || true)
  [[ ${#SCENARIOS[@]} -gt 0 ]] || { echo "Немає сценаріїв у $DIR"; exit 2; }
  PICK="${SCENARIOS[$RANDOM % ${#SCENARIOS[@]}]}"
fi
ID="$(basename "$PICK" .b64)"

# Ціль виконання читається зі сценарію, але на екран не потрапляє
TARGET="$(base64 -d < "$PICK" | sed -n 's/^#TARGET: //p' | head -1)"
: "${TARGET:=ssh}"

run_ssh() {
  : "${LAB_HOST:?LAB_HOST не заданий}"; : "${LAB_SSH_USER:=deploy}"; : "${LAB_SSH_PORT:=22}"
  local opts=(-o BatchMode=yes -o StrictHostKeyChecking=accept-new -p "$LAB_SSH_PORT")
  [[ -n "${BASTION_HOST:-}" ]] && opts+=(-J "$BASTION_HOST")
  ssh "${opts[@]}" "${LAB_SSH_USER}@${LAB_HOST}" "test -f /etc/devops-lab" \
    || { echo "На цілі немає /etc/devops-lab. Відмовляюся ламати."; exit 3; }
  base64 -d < "$PICK" | ssh "${opts[@]}" "${LAB_SSH_USER}@${LAB_HOST}" "sudo bash -s" >/dev/null 2>&1 || true
}

run_local() {   # az, gh, terraform — з твоїми обліковими даними
  [[ -f .devops-lab ]] || { echo "У корені репозиторію немає файлу .devops-lab. Відмовляюся ламати."; exit 3; }
  base64 -d < "$PICK" | bash -s >/dev/null 2>&1 || true
}

run_kubectl() {
  : "${LAB_KUBE_CONTEXT:?LAB_KUBE_CONTEXT не заданий}"; : "${LAB_NAMESPACE:=app-dev}"
  kubectl --context "$LAB_KUBE_CONTEXT" get ns "$LAB_NAMESPACE" -o jsonpath='{.metadata.labels.devops-lab}' 2>/dev/null \
    | grep -q true || { echo "Namespace $LAB_NAMESPACE не має мітки devops-lab=true. Відмовляюся ламати."; exit 3; }
  base64 -d < "$PICK" | bash -s >/dev/null 2>&1 || true
}

case "$TARGET" in
  ssh)     run_ssh ;;
  local)   run_local ;;
  kubectl) run_kubectl ;;
  *) echo "Невідома ціль сценарію: $TARGET"; exit 4 ;;
esac

printf '%s %s\n' "$ID" "$(date -u +%s)" > .incident-state
cat <<MSG

Інцидент запущено (ціль: ${TARGET}). Що саме зламано — не сказано навмисно.

  Початок:    $(date -u '+%H:%M:%S UTC')
  Мета:       відновити сервіс і зафіксувати таймлайн.
  Підказки:   prompts/05-incident-master.md (після 60 хвилин без прогресу)
  Закриття:   ./verify/run.sh ${STAGE}  →  зелено  →  ./incidents/reveal.sh

MSG
