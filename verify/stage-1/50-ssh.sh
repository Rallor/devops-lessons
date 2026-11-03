#!/usr/bin/env bash
# Блок 1.4 — SSH і доступ
. "$(dirname "$0")/../lib/common.sh"

log "SSH: ключі, root, bastion"

# Пароль не приймається (перевіряємо ззовні, з раннера)
check_fails "автентифікація паролем відхилена" \
  ssh -o BatchMode=no -o PreferredAuthentications=password -o PubkeyAuthentication=no \
      -o StrictHostKeyChecking=no -o ConnectTimeout=8 -p "$LAB_SSH_PORT" \
      "${LAB_SSH_USER}@${LAB_HOST}" true

check "PermitRootLogin вимкнено"        ssh_lab "sudo sshd -T 2>/dev/null | grep -qi '^permitrootlogin no'"
check "PasswordAuthentication вимкнено" ssh_lab "sudo sshd -T 2>/dev/null | grep -qi '^passwordauthentication no'"

if [[ -n "$BASTION_HOST" ]]; then
  check_fails "прямий SSH ззовні закритий" port_open "$LAB_HOST" "$LAB_SSH_PORT"
else
  skip "прямий SSH ззовні закритий" "BASTION_HOST не заданий"
fi

summary
