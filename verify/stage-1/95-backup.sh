#!/usr/bin/env bash
# Блок 1.9 — бекап
. "$(dirname "$0")/../lib/common.sh"

log "Бекап і відновлюваність"

check "останній дамп свіжіший за 26 год" ssh_lab "find /var/backups/app -name '*.dump' -mmin -1560 | grep -q ."
check "бекап не порожній"                ssh_lab "find /var/backups/app -name '*.dump' -size +10k | grep -q ."
check "ротація працює (не більше N копій)" ssh_lab "[ \"\$(find /var/backups/app -name '*.dump' | wc -l)\" -le 14 ]"
check "останній запуск backup.service успішний" ssh_lab "systemctl show backup.service -p ExecMainStatus --value | grep -q '^0$'"
check "звіт про restore існує в репозиторії" bash -c "grep -riq 'restore' docs/ runbook.md 2>/dev/null"

summary
