#!/usr/bin/env bash
# Спільні функції перевірок. Підключається кожним скриптом у verify/stage-*/.
set -uo pipefail

PASS=0; FAIL=0; SKIP=0
REPORT="${REPORT:-verify-report.md}"

# Параметри стенда беруться з lab.env (див. lab.env.example)
: "${LAB_HOST:?LAB_HOST не заданий (домен або IP стенда)}"
: "${LAB_DOMAIN:=$LAB_HOST}"
: "${LAB_SSH_USER:=deploy}"
: "${LAB_SSH_PORT:=22}"
: "${BASTION_HOST:=}"
: "${ALLOW_DESTRUCTIVE:=0}"   # reboot та інші руйнівні перевірки

log()  { printf '%s\n' "$*"; }
note() { printf '  %s\n' "$*"; }

ok()   { PASS=$((PASS+1)); printf '  [ OK ] %s\n' "$1"; printf -- '- [x] %s\n' "$1" >> "$REPORT"; }
bad()  { FAIL=$((FAIL+1)); printf '  [FAIL] %s\n' "$1"; printf -- '- [ ] **%s** — %s\n' "$1" "${2:-}" >> "$REPORT"; }
skip() { SKIP=$((SKIP+1)); printf '  [SKIP] %s (%s)\n' "$1" "${2:-}"; printf -- '- [~] %s — пропущено: %s\n' "$1" "${2:-}" >> "$REPORT"; }

# check "назва" "команда" — успіх, якщо команда повертає 0
check() {
  local name="$1"; shift
  local out
  if out=$("$@" 2>&1); then ok "$name"; else bad "$name" "$(printf '%s' "$out" | tail -3 | tr '\n' ' ')"; fi
}

# check_fails "назва" "команда" — успіх, якщо команда НЕ повертає 0 (порт закритий тощо)
check_fails() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then bad "$name" "команда несподівано успішна: $*"; else ok "$name"; fi
}

ssh_lab() {
  local opts=(-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -p "$LAB_SSH_PORT")
  [[ -n "$BASTION_HOST" ]] && opts+=(-J "$BASTION_HOST")
  ssh "${opts[@]}" "${LAB_SSH_USER}@${LAB_HOST}" "$@"
}

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$1"; }

port_open() { # port_open host port
  if command -v nc >/dev/null; then nc -z -w5 "$1" "$2"; else timeout 5 bash -c ">/dev/tcp/$1/$2"; fi
}

summary() {
  printf '\n  ---\n  OK: %s   FAIL: %s   SKIP: %s\n' "$PASS" "$FAIL" "$SKIP"
  printf '\n**Підсумок:** OK %s / FAIL %s / SKIP %s\n' "$PASS" "$FAIL" "$SKIP" >> "$REPORT"
  [[ "$FAIL" -eq 0 ]]
}
