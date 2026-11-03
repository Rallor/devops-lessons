# Ручні пункти етапу 2
| Пункт | Артефакт |
|---|---|
| Знищений staging відтворено з нуля за ≤30 хв | `docs/evidence/rebuild.log` із таймстемпами |
| Другий прогін playbook: `changed=0` | вивід прогону |
| `docker compose up` на чистій машині дає робочий стек | скрінкаст або лог |
| Образи non-root, з лімітами й healthcheck | вивід `docker inspect` |
