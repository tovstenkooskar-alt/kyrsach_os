# ТЗ-02 · Инцидент на сервере приёма платежей billing-02

| | |
|---|---|
| Практикант 1 | Товстенко Оскар, группа 9/2-РПО-25/1 — диск: замеры `df`/`du`, старые журналы и дамп, перенос выгрузки, `cleanup-logs.sh` |
| Практикант 2 | Товстенко Оскар — процессы и настройки: нагрузка, дерево процессов, уровень журнала, права `billing.conf`, перезапуск `billing-api`, остановка сверки |
| Сервер | копия billing-02 на виртуальной машине `oskar_os` (внутри системы пользователь `oskar`, hostname `billing-02`, Ubuntu 26.04.1) |
| Итог приёмки | 12 из 12 (файл `acceptance.txt`) |

Напарник не назначался: обе части сделаны на одной машине. Команды и числа ниже сняты с этой виртуальной машины 1 ноября 2026, время в журнале — как его показала команда `date` (UTC).

## Состав репозитория

- `server-passport.md` — паспорт сервера до изменений
- `runbook.md` — журнал работ
- `postmortem.md` — разбор инцидента
- `cleanup-logs.sh` — профилактика раздела журналов
- `acceptance.txt` — вывод приёмки, 12 из 12
- `optional/disk-watch.sh`, `optional/snapshot.sh` — задачи по выбору
- `screenshots/` — замеры, дерево процессов, приёмка

## Как воспроизвести

Стенд после перезагрузки виртуальной машины нужно развернуть заново: раздел журналов — это loop-файл.

```bash
cd ~/Downloads
wget -O billing-stand.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/billing-stand.sh
wget -O billing-acceptance.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/billing-acceptance.sh
sudo bash billing-stand.sh
```

Дальше команды из `runbook.md` по порядку: сначала замеры, потом перенос выгрузки, правка `/etc/billing/billing.conf`, `sudo bash cleanup-logs.sh --apply`, сигнал `TERM` службе `billing-api`, остановка `billing-report` (рабочий процесс 1 не завершается по `TERM`, его останавливает `KILL`). Супервизор `billingd` не останавливать.

Приёмка:

```bash
sudo bash ~/Downloads/billing-acceptance.sh | tee acceptance.txt
```

Не получилось: отдельный репозиторий GitHub и ревью второго практиканта — второго человека в паре не было.

Нейросеть использовалась для: разбора текста ТЗ, выполнения команд на виртуальной машине и оформления документов по выводу этих команд.
