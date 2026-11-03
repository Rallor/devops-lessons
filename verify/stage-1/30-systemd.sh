#!/usr/bin/env bash
# Блок 1.2 — systemd
. "$(dirname "$0")/../lib/common.sh"

log "systemd: юніти, рестарти, timers"

check "app@1 активний"            ssh_lab systemctl is-active --quiet app@1
check "app@2 активний"            ssh_lab systemctl is-active --quiet app@2
check "worker активний"           ssh_lab systemctl is-active --quiet worker
check "app@1 в автозапуску"       ssh_lab systemctl is-enabled --quiet app@1
check "worker в автозапуску"      ssh_lab systemctl is-enabled --quiet worker
check "немає failed-юнітів"       ssh_lab "[ -z \"\$(systemctl list-units --failed --no-legend)\" ]"

# Сервіс не працює від root
check "app@1 працює не від root"  ssh_lab "systemctl show app@1 -p User --value | grep -qv '^root\$'"

# Hardening
for opt in NoNewPrivileges ProtectSystem PrivateTmp; do
  check "app@1: $opt задано" ssh_lab "v=\$(systemctl show app@1 -p $opt --value); [ -n \"\$v\" ] && [ \"\$v\" != 'no' ] && [ \"\$v\" != 'false' ]"
done

# Політика рестартів
check "app@1: Restart != no"      ssh_lab "systemctl show app@1 -p Restart --value | grep -qv '^no\$'"
check "worker: TimeoutStopSec > 30s" ssh_lab "v=\$(systemctl show worker -p TimeoutStopUSec --value); echo \"\$v\" | grep -qE '([3-9][0-9]|[0-9]{3,})s|min'"

# Timer бекапу
check "backup.timer активний"     ssh_lab systemctl is-active --quiet backup.timer
check "backup.timer має наступний запуск" ssh_lab "systemctl list-timers backup.timer --no-legend | grep -qv '^\\s*-'"

# Журнал обмежений
check "journald: SystemMaxUse задано" ssh_lab "grep -Eq '^[[:space:]]*SystemMaxUse=' /etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf 2>/dev/null"

# Юніти лежать у git, а не тільки на сервері
check "юніти є в репозиторії" bash -c 'ls **/app@.service */app@.service 2>/dev/null | head -1 | grep -q .'

summary
