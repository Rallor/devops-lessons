# Блок 3.2 — GitHub Actions

**Час:** ~7 год · **Передумови:** 3.1

## Навіщо це зараз
Це інструмент, у якому житиме вся доставка. Заразом це найпопулярніший вектор атак на ланцюжок постачання в 2025–2026 роках, тож безпеку вчимо одразу, а не в кінці курсу.

## Теорія
- Workflow YAML: `on` (push, pull_request, schedule, workflow_dispatch), `jobs`, `steps`, `needs`, `if`.
- Runners: hosted проти self-hosted; ризики self-hosted для публічних репозиторіїв.
- Matrix, reusable workflows, composite actions.
- Контексти `secrets` і `vars`; `GITHUB_TOKEN` і блок `permissions`; environments з required reviewers.
- `pull_request_target` і `workflow_run`: чому вони віддають секрети коду з форку.
- Пінінг actions за повним SHA, immutable releases, Dependabot або Renovate; `zizmor` і `actionlint`.

## Завдання
1. Напиши workflow для PR: lint, тести, білд образу без публікації.
2. Винеси білд і публікацію образу в reusable workflow, який викликають і API, і воркер.
3. Додай matrix для двох версій рантайму, якщо це має сенс для твого застосунку.
4. Виставь `permissions` явно в кожному workflow за принципом мінімальних прав.
5. Створи environment `production` з required reviewer; переконайся, що деплой чекає підтвердження.
6. Запінь усі сторонні actions за повним SHA; додай Renovate або Dependabot для оновлення пінів.
7. Прожени `zizmor` (або `actionlint`) і виправ знахідки.
8. Навмисно зроби workflow із `pull_request_target`, який використовує секрет; покажи через `zizmor`, чому це небезпечно, і прибери.
9. Налаштуй сповіщення в Telegram або Slack про падіння пайплайну.

## Критерії прийому
- [ ] У кожного workflow явний `permissions`
- [ ] Усі сторонні actions запінені за SHA
- [ ] `zizmor` без знахідок високого рівня
- [ ] Prod-деплой вимагає approval
- [ ] Падіння пайплайну дає сповіщення

## Пастки
- `permissions: write-all` за замовчуванням дає токену більше прав, ніж потрібно для 95% джобів.
- Пін за тегом (`@v4`) не захищає: теги перезаписуються, і саме так зламали trivy-action у березні 2026.
- Секрет, переданий у `echo` для дебагу, лишається в логах назавжди.
- Self-hosted runner без ізоляції зберігає стан між запусками, включно зі слідами чужого коду.

## Підказки
<details><summary>Підказка 1</summary>
SHA для піна беруть із конкретного релізу action і лишають коментар із версією поруч: `uses: actions/checkout@<sha> # v5.0.0`.
</details>
<details><summary>Підказка 2</summary>
Якщо потрібен доступ до секретів у PR із форку — перепроєктуй процес, а не додавай `pull_request_target`. Це майже завжди означає розділення на два workflow.
</details>

## Тест
`prompts/04-quiz.md`, тема: «GitHub Actions: тригери, permissions, пінінг, безпека», 8 питань.
