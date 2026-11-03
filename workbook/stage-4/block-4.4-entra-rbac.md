# Блок 4.4 — Entra ID і RBAC

**Час:** ~5 год · **Передумови:** 4.3

## Навіщо це зараз
Аудитор із тригера етапу питає не «що зламалось», а «хто мав право це змінити». Відповідь дає модель доступу, а не пояснення.

## Теорія
- Users, groups, service principals, managed identities (system- і user-assigned): коли який тип.
- RBAC: вбудовані ролі (Owner, Contributor, Reader) і сервісні (AcrPull, Key Vault Secrets User); scope і наслідування.
- Найменші права на практиці; чому «Owner для всіх» — антипатерн; PIM концептуально.
- Workload identity federation (OIDC) для CI замість client secret.

## Завдання
1. Опиши в коді групи: платформа, розробники, читачі; роздай ролі групам, а не людям.
2. Прибери Owner у всіх людей; лиши мінімально достатні ролі, перевір `az role assignment list`.
3. Створи user-assigned managed identity для застосунку і дай їй лише `Key Vault Secrets User` і `AcrPull`.
4. Перевір негативно: спробуй із цієї ідентичності зробити те, чого не має бути дозволено, і покажи відмову.
5. Налаштуй federated credential для GitHub із обмеженням на репозиторій і environment.
6. Опиши в `docs/notes/access-model.md` матрицю: хто, до чого, з яким scope і чому.

## Критерії прийому
- [ ] Ролі роздані групам; жодного Owner у людей
- [ ] Managed identity застосунку має лише дві потрібні ролі
- [ ] Негативна перевірка задокументована
- [ ] Матриця доступу існує і читається

## Пастки
- Роль на рівні subscription замість resource group дає більше, ніж потрібно, і назавжди.
- Service principal із секретом, який ніхто не ротує, — довічний ключ від інфраструктури.
- Права через персональні призначення неможливо аудитувати після звільнення людини.

## Підказки
<details><summary>Підказка 1</summary>
`az role assignment list --all --include-inherited -o table` показує реальну картину, включно з успадкованими правами.
</details>
<details><summary>Підказка 2</summary>
Сервісні ролі шукай за призначенням: для pull образів достатньо AcrPull, Contributor на ACR не потрібен.
</details>

## Тест
`prompts/04-quiz.md`, тема: «ідентичності, RBAC, scope, OIDC», 8 питань.
