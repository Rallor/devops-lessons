# Блок 1.2 — systemd і планування задач

**Час:** ~6 год · **Verify:** `verify/stage-1/30-systemd.sh` · **Передумови:** 1.0, 1.1

## Навіщо це зараз

Застосунок запускається командою `python main.py` у сесії розробника. Демо — у понеділок. Якщо VM перезавантажать, або процес упаде, або ти закриєш SSH-сесію, показувати буде нічого. Вимоги етапу 3 і 4 («переживає reboot», «рестарт без 502») закриваються саме цим блоком. Бекап із блока 1.9 теж поїде на systemd timer, а не на cron.

## Теорія

Читаємо офіційне, не переспіви:

- `man systemd.unit`, `man systemd.service`, `man systemd.exec` — секції `[Unit]`, `[Service]`, `[Install]`.
- `man systemd.timer`, `man systemd.time` — синтаксис `OnCalendar`, `Persistent=`.
- `man journalctl`, `man journald.conf` — фільтри, ротація, `SystemMaxUse`.
- freedesktop.org: types `simple`, `exec`, `forking`, `oneshot`, `notify` — чим відрізняються і як systemd розуміє, що сервіс піднявся.

Мінімум, який має вкластися в голову:

1. Чому systemd замінив SysV init: паралельний запуск і залежності замість послідовних скриптів. Стан 2026 року: cgroup v1 прибрано (systemd 258), SysV-скрипти виводяться з підтримки — `/etc/init.d` у новій системі не розраховуємо.
2. `Requires=` vs `Wants=` vs `After=`: перші два про залежність, третій про порядок. Плутанина тут дає сервіс, який стартує до бази.
3. `Restart=on-failure` vs `always`, `RestartSec=`, і чому без `StartLimitIntervalSec` сервіс у циклі падіння вбʼє CPU.
4. `TimeoutStopSec=`: скільки systemd чекає після SIGTERM, перш ніж надіслати SIGKILL. Звʼязок із блоком 1.1.
5. Шаблонні юніти `app@.service`: один файл — багато інстансів, `%i` як параметр.
6. Базовий hardening: `NoNewPrivileges=`, `ProtectSystem=strict`, `PrivateTmp=`, `ReadWritePaths=`.
7. Timer проти cron: логи в journald, залежності, `Persistent=true` для пропущених запусків на вимкненій машині.

## Завдання

1. Створи системного користувача `appsvc` без shell і без sudo; каталог застосунку належить йому.
2. Напиши `app@.service` — шаблонний юніт, що піднімає інстанс на порту `80%i` (тобто `app@1` → 8001, `app@2` → 8002). Конфіг — через `EnvironmentFile=`, не через хардкод у `ExecStart`.
3. Увімкни два інстанси: `systemctl enable --now app@1 app@2`.
4. Напиши `worker.service` для фонового воркера. Воркер має **дороблювати поточну задачу** після SIGTERM: постав `TimeoutStopSec=90` і переконайся, що застосунок реально обробляє сигнал.
5. Додай `Restart=on-failure`, `RestartSec=5` і ліміт рестартів, щоб цикл падіння не зʼїв машину.
6. Застосуй три опції hardening до обох юнітів. Перевір, що сервіс після цього ще працює — саме тут більшість ламає запис у лог-каталог.
7. Створи `backup.service` (`Type=oneshot`) і `backup.timer` (`OnCalendar=daily`, `Persistent=true`). Сам скрипт бекапу — блок 1.9; поки що досить `echo` із записом у журнал.
8. Обмеж журнал: `SystemMaxUse=500M` у `journald.conf`, перевір `journalctl --disk-usage`.
9. Зламай юніт навмисно (невірний шлях у `ExecStart`), подивись `systemctl status` і `journalctl -u app@1 -p err`, полагодь. Запиши в `runbook.md`, як саме ти це діагностував.

## Критерії прийому

- [ ] `verify/stage-1/30-systemd.sh` зелений
- [ ] `systemctl list-units --failed` порожній
- [ ] Після `reboot` обидва інстанси й воркер піднімаються без ручних дій
- [ ] `kill -TERM` воркера в момент обробки задачі не втрачає задачу (лог показує завершення)
- [ ] `systemctl show app@1 -p NoNewPrivileges,ProtectSystem,PrivateTmp` повертає непорожні значення
- [ ] `systemctl list-timers` показує `backup.timer` із наступним запуском
- [ ] Юніти лежать у git, не тільки на сервері

## Пастки

- Сервіс «працює», але `systemctl status` показує `activating` нескінченно: невірний `Type=` для застосунку, який форкається.
- `ExecStart=` з пайпом, редиректом або `&&` — не спрацює: це не shell. Або `/bin/sh -c`, або окремий скрипт.
- Після `ProtectSystem=strict` сервіс падає на запису в `/var/log/...`, і в статусі видно read-only file system.
- Змінив unit-файл, зробив `restart`, нічого не змінилось — забутий `daemon-reload`.
- `Restart=always` на `Type=oneshot` дає нескінченний цикл.
- Порт зайнятий, бо старий процес лишився поза cgroup сервісу (запускався руками з SSH).

## Підказки

<details><summary>Підказка 1 — куди дивитися (після 45 хв)</summary>

- Статус юніта завжди читай разом із журналом: `systemctl status app@1 --no-pager -l` і поруч `journalctl -u app@1 -n 50 --no-pager`.
- Для шаблонних юнітів `%i` — те, що після `@`. Подивись у `man systemd.unit` розділ про специфікатори.
- Якщо сервіс не бачить змінних — перевір саме шлях у `EnvironmentFile=` і права на файл: сервіс читає його від імені `User=`.
</details>

<details><summary>Підказка 2 — що саме робити (після ще 30 хв)</summary>

- Тип для звичайного застосунку, який не форкається і слухає порт, — `simple` (або `exec`, якщо треба, щоб systemd вважав старт успішним лише після реального запуску бінарника).
- `ProtectSystem=strict` робить увесь `/` тільки для читання. Каталоги, куди сервіс пише, додаються явно через `ReadWritePaths=` або `StateDirectory=`/`LogsDirectory=`.
- Цикл падіння обмежується парою `StartLimitIntervalSec=` і `StartLimitBurst=` у секції `[Unit]`.
- Порядок дій після будь-якої правки файлу: `daemon-reload` → `restart` → `status` → `journalctl`.
</details>

<details><summary>Розбір — повне рішення</summary>

`/etc/systemd/system/app@.service`:

```ini
[Unit]
Description=App instance %i
After=network-online.target postgresql.service
Wants=network-online.target
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
Type=simple
User=appsvc
Group=appsvc
WorkingDirectory=/opt/app
EnvironmentFile=/etc/app/app.env
Environment=PORT=80%i
ExecStart=/opt/app/.venv/bin/python -m app.main
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
NoNewPrivileges=true
ProtectSystem=strict
PrivateTmp=true
StateDirectory=app
LogsDirectory=app

[Install]
WantedBy=multi-user.target
```

`worker.service` відрізняється тим, що `TimeoutStopSec=90`, а сам воркер ловить SIGTERM і завершує поточну задачу. Якщо застосунок сигнал не обробляє — це баг застосунку, і його треба або виправити, або чесно записати в ADR як відомий ризик.

`backup.timer`:

```ini
[Unit]
Description=Daily database backup

[Timer]
OnCalendar=daily
RandomizedDelaySec=15m
Persistent=true

[Install]
WantedBy=timers.target
```

Перевірка: `systemd-analyze verify /etc/systemd/system/app@.service` ловить частину помилок до запуску.
</details>

## Тест

`prompts/04-quiz.md`, тема: «systemd: типи юнітів, залежності, рестарти, сигнали, timers», 6–8 питань, поріг 90%. Каверзне питання буде про різницю `Requires` і `After` або про поведінку `TimeoutStopSec`.
