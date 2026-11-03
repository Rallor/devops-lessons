#!/usr/bin/env bash
# Блок 1.7 — nginx: балансування і рестарт без 502
. "$(dirname "$0")/../lib/common.sh"

log "nginx: upstream і поведінка під рестартом"

check "конфіг nginx валідний" ssh_lab "sudo nginx -t"
check "в upstream ≥2 бекенди" ssh_lab "grep -A10 -r 'upstream' /etc/nginx/ 2>/dev/null | grep -c 'server ' | awk '{exit (\$1>=2)?0:1}'"

# Рестарт одного інстансу під навантаженням не має давати 502
log "  рестарт app@1 під curl-циклом (40 запитів)..."
ssh_lab "sudo systemctl restart app@1" &
RESTART_PID=$!
errors=0
for _ in $(seq 1 40); do
  code=$(http_code "https://$LAB_DOMAIN/healthz")
  [[ "$code" == "200" ]] || errors=$((errors+1))
  sleep 0.25
done
wait "$RESTART_PID" 2>/dev/null
if [[ "$errors" -eq 0 ]]; then ok "рестарт інстансу без помилок для користувача"
else bad "рестарт інстансу без помилок для користувача" "невдалих запитів: $errors з 40"; fi

summary
