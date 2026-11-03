# Блок 4.6 — Compute, дані, сховище

**Час:** ~6 год · **Передумови:** 4.5

## Навіщо це зараз
Тут ти вперше платиш за керованість грішми і маєш назвати, що саме купив: PITR, HA, патчі — і що втратив у контролі.

## Теорія
- VM і VMSS: сайзинг, availability zones. App Service: плани, deployment slots, swap. ACI і Container Apps.
- ACR: рівні, pull через managed identity, retention.
- Storage Account: Blob, рівні Hot/Cool/Archive, lifecycle policy для архіву бекапів.
- PostgreSQL Flexible Server: HA, PITR, read replicas, maintenance window.
- SQL проти NoSQL: практичні критерії, не мода.
- Key Vault: секрети, RBAC-модель, soft delete, purge protection, посилання з App Service.

## Завдання
1. Реалізуй compute за ADR-012; якщо App Service — налаштуй два slots і перевір swap.
2. Перенеси БД на Flexible Server; увімкни PITR і зафіксуй retention.
3. Перевір PITR: віднови базу на момент пʼять хвилин тому в нову інстанцію, заміряй час.
4. Перенеси бекапи в Blob із lifecycle policy: гарячі 30 днів, потім архів.
5. Переведи всі секрети в Key Vault; застосунок бере їх через managed identity, а не зі змінних.
6. Налаштуй pull образів із ACR через managed identity; прибери логін і пароль.
7. Порівняй у нотатках місячну вартість керованої БД і БД на VM з урахуванням твого часу на обслуговування.

## Критерії прийому
- [ ] Застосунок працює на обраному compute; slots або еквівалент перевірені
- [ ] PITR-відновлення виконано, час записаний
- [ ] Бекапи в Blob із lifecycle
- [ ] У конфігурації застосунку немає паролів — лише посилання на Key Vault
- [ ] ACR pull через identity

## Пастки
- Soft delete у Key Vault означає, що імʼя видаленого секрету не звільняється одразу.
- Swap slots переносить і налаштування, якщо вони не позначені як slot-specific.
- Flexible Server у зоні без HA дає простій під час maintenance window.
- Archive tier дешевий на зберіганні і дорогий на відновленні; для бекапів це має значення.

## Підказки
<details><summary>Підказка 1</summary>
PITR створює нову інстанцію, а не перезаписує стару. План відновлення має враховувати, що далі треба перемкнути застосунок.
</details>
<details><summary>Підказка 2</summary>
Key Vault references у App Service працюють лише коли identity має роль на сам Key Vault; перевіряй через сторінку діагностики.
</details>

## Тест
`prompts/04-quiz.md`, тема: «compute-варіанти, PITR, Key Vault, сховище», 8 питань.
