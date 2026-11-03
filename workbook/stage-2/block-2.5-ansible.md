# Блок 2.5 — Ansible

**Час:** ~8 год · **Передумови:** Етап 1 повністю

## Навіщо це зараз
Твій `runbook.md` з Етапу 1 — це специфікація. Зараз він перетворюється на код, і після цього видаляється: документ, який дублює код, завжди відстає.

## Теорія
- YAML-синтаксис playbook, tasks, модулі; чому не `shell` для всього.
- Inventory: групи dev/staging/prod, `group_vars`, `host_vars`; динамічний inventory — концептуально.
- Ролі: tasks, handlers, templates, vars, defaults; Jinja2 для конфігів.
- Ідемпотентність: `changed` проти `ok`, `--check --diff`, `creates`, `changed_when`.
- Handlers і `notify`: рестарт лише при реальній зміні.
- `ansible-vault` або SOPS для секретів; `ansible-lint` і Molecule.

## Завдання
1. Створи inventory з групами і змінними для staging і prod.
2. Напиши роль `base`: користувачі, SSH hardening, firewall, unattended-upgrades, часова зона.
3. Напиши роль `app`: Docker, каталоги, compose-файл із шаблону Jinja2, systemd-юніт або compose-сервіс за ADR-004.
4. Напиши роль `nginx`: конфіг із шаблону, сертифікати, handler на reload (не restart).
5. Винеси секрети у vault або SOPS; переконайся, що в git немає відкритих значень.
6. Прогони playbook на чистій VM, заміряй час від нуля до працюючого staging.
7. Прогони вдруге: `changed=0`. Якщо ні — знайди неідемпотентні задачі й полагодь.
8. Прогони `--check --diff` і покажи, що він нічого не змінює.
9. Додай `ansible-lint` у pre-commit.
10. Видали `runbook.md` із ручними кроками, лишивши тільки «як запустити playbook» і аварійні процедури.

## Критерії прийому
- [ ] Чиста VM → працюючий staging однією командою, час записаний
- [ ] Другий прогін: `changed=0`
- [ ] `ansible-lint` без помилок
- [ ] Секрети зашифровані; `gitleaks` чистий
- [ ] Handler рестартує nginx лише при зміні конфігу

## Пастки
- `shell`/`command` без `creates` або `changed_when` дають `changed` на кожному прогоні.
- `template` із `notify`, але handler у неправильному місці — рестарт не відбувається.
- Ansible за замовчуванням не зупиняється на помилці одного хоста в групі — перевір стратегію.
- Vault-пароль у репозиторії зводить нанівець весь vault.

## Підказки
<details><summary>Підказка 1</summary>
Щоб знайти неідемпотентні задачі: `ansible-playbook site.yml --diff | grep -B5 changed`. Найчастіші винуватці — `shell`, `file` з правами і `lineinfile`.
</details>
<details><summary>Підказка 2</summary>
Шаблон nginx краще робити з `validate: nginx -t -c %s`, щоб зламаний конфіг не доїхав до сервера.
</details>

## Тест
`prompts/04-quiz.md`, тема: «Ansible: ідемпотентність, ролі, handlers, vault», 8 питань.
