#!/usr/bin/env bash
# Блок 1.6 — firewall і закритість сервісів
. "$(dirname "$0")/../lib/common.sh"

log "Мережева поверхня ззовні"

check "80 відкритий"  port_open "$LAB_HOST" 80
check "443 відкритий" port_open "$LAB_HOST" 443

for p in 5432 6379 8001 8002 3000 9090; do
  check_fails "порт $p закритий ззовні" port_open "$LAB_HOST" "$p"
done

check "Postgres слухає лише локально" ssh_lab "ss -tlnp 2>/dev/null | grep ':5432' | grep -qvE '0\\.0\\.0\\.0|\\[::\\]'"
check "firewall має політику deny"    ssh_lab "sudo ufw status verbose 2>/dev/null | grep -qi 'deny (incoming)' || sudo nft list ruleset 2>/dev/null | grep -qi 'policy drop'"

summary
