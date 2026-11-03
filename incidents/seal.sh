#!/usr/bin/env bash
# Запечатує сценарій: ./incidents/seal.sh <етап> <файл.sh> [id]
set -euo pipefail
cd "$(dirname "$0")/.."
STAGE="$1"; SRC="$2"; ID="${3:-$(basename "$SRC" .sh)}"
grep -q '^#TARGET: \(ssh\|local\|kubectl\)$' "$SRC" || { echo "Немає рядка '#TARGET: ssh|local|kubectl'"; exit 2; }
grep -q '^#SOLUTION: ' "$SRC" || { echo "Немає рядків '#SOLUTION: ' з розбором"; exit 2; }
case "$(sed -n 's/^#TARGET: //p' "$SRC" | head -1)" in
  ssh)     grep -q '/etc/devops-lab' "$SRC" || { echo "ssh-сценарій має перевіряти /etc/devops-lab"; exit 2; } ;;
  local)   grep -qE 'LAB_RG|LAB_REPO|devops-lab' "$SRC" || { echo "local-сценарій має перевіряти межі лабораторії"; exit 2; } ;;
  kubectl) grep -q 'LAB_NAMESPACE' "$SRC" || { echo "kubectl-сценарій має працювати лише в LAB_NAMESPACE"; exit 2; } ;;
esac
mkdir -p "incidents/stage-${STAGE}"
base64 < "$SRC" > "incidents/stage-${STAGE}/${ID}.b64"
echo "Запечатано: incidents/stage-${STAGE}/${ID}.b64 — тепер видали вихідний файл"
