# Блок 6.3 — kubectl і Helm

**Час:** ~5 год · **Передумови:** 6.1

## Навіщо це зараз
Помилки в кластері зʼясовуються не читанням YAML, а трьома-чотирма командами. І шаблон сервісу, який ти зробиш тут, стане тим, що інша команда використає без тебе.

## Теорія
- `get`, `describe`, `logs --previous`, `exec`, `port-forward`, `events`, `top`.
- Діагностика станів: CrashLoopBackOff, Pending, ImagePullBackOff, OOMKilled.
- Helm: chart, `values.yaml`, шаблони, `install`/`upgrade`/`rollback`; `helm template` і `lint` у CI.
- Helm 4: server-side apply і WASM-плагіни; Helm 3 ще підтримується — вибір версії фіксуй у CI.
- Library chart як «золотий шаблон» сервісу для команд.

## Завдання
1. Відтвори по черзі чотири стани помилок (CrashLoopBackOff, Pending, ImagePullBackOff, OOMKilled) і для кожного запиши в нотатки послідовність команд, яка приводить до причини.
2. Запакуй свій застосунок у Helm chart із values для dev, staging, prod.
3. Винеси спільне в library chart; зроби другий сервіс на його основі за 15 хвилин.
4. Додай `helm lint` і `helm template` у CI; шаблон, що не рендериться, валить пайплайн.
5. Зроби `upgrade`, потім `rollback`; подивись на історію релізів.
6. Порівняй поведінку `helm upgrade` з server-side apply і без нього на прикладі поля, зміненого руками.
7. Напиши онбординг-документ «як вивести новий сервіс» на одну сторінку.

## Критерії прийому
- [ ] Таблиця «стан пода → команди діагностики → причина» заповнена
- [ ] Chart параметризований для трьох середовищ
- [ ] Другий сервіс піднятий на library chart
- [ ] `helm lint` у CI; rollback перевірений
- [ ] Онбординг-документ існує і читається стороннім

## Пастки
- `kubectl logs` без `--previous` не покаже логи впалого контейнера.
- Pending майже завжди про ресурси, taints або PVC, а не про «кластер зламався».
- Helm 4 із server-side apply інакше поводиться з полями, які змінили руками: будуть конфлікти field manager.

## Підказки
<details><summary>Підказка 1</summary>
Порядок діагностики: `get pod` → `describe pod` (дивись Events унизу) → `logs --previous` → `get events`.
</details>
<details><summary>Підказка 2</summary>
Library chart підключається як залежність із `type: library`; шаблони в ньому починаються з `_`.
</details>

## Тест
`prompts/04-quiz.md`, тема: «діагностика подів, Helm, values, rollback», 8 питань.
