#!/usr/bin/env bash
# Блок 1.5 — DNS, HTTP, TLS
. "$(dirname "$0")/../lib/common.sh"

log "DNS і TLS"

check "A-запис резолвиться"        bash -c "getent hosts '$LAB_DOMAIN' >/dev/null"
check "HTTPS відповідає 200"       bash -c "[ \"\$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 https://$LAB_DOMAIN/)\" = 200 ]"
check "HTTP редиректить на HTTPS"  bash -c "curl -sI --max-time 10 http://$LAB_DOMAIN/ | head -1 | grep -qE ' 30[18] '"
check "TLS не нижче 1.2"           bash -c "echo | openssl s_client -connect $LAB_DOMAIN:443 -tls1_2 >/dev/null 2>&1"
check "ланцюжок сертифіката валідний" bash -c "curl -sS --max-time 10 https://$LAB_DOMAIN/ -o /dev/null"

# Строк дії: з 2026 сертифікати короткі, тому поріг низький, але алерт має бути раніше
check "сертифікат живий ще >14 днів" bash -c "
  end=\$(echo | openssl s_client -connect $LAB_DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
  left=\$(( (\$(date -d \"\$end\" +%s) - \$(date +%s)) / 86400 ))
  echo \"залишилось днів: \$left\"; [ \"\$left\" -gt 14 ]"

# Пошта
for rec in "v=spf1" "v=DMARC1"; do
  host="$LAB_DOMAIN"; [[ "$rec" == "v=DMARC1" ]] && host="_dmarc.$LAB_DOMAIN"
  check "DNS TXT містить $rec" bash -c "dig +short TXT '$host' | grep -q '$rec'"
done

summary
