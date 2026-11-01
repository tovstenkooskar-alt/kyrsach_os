# Паспорт сервера · billing-02 · 2026-11-01

Снят до команд, которые меняют сервер. Копия стенда развёрнута в 16:00:22 UTC. Замеры нагрузки — в 16:01:12 UTC, после паузы, без каких-либо изменений. Команды на копии сервера выполняет пользователь `oskar`, hostname машины — `billing-02`.

| Сведение | Команда | Что показала |
|---|---|---|
| Версия системы и ядра | `cat /etc/os-release`, `uname -a` | Ubuntu 26.04.1 LTS, Linux 7.0.0-38-generic, x86_64 |
| Процессор и память | `nproc`, `free -h` | 4 ядра; память 5.7 Gi, занято около 1.3 Gi, swap нет |
| Разделы | `df -h` | `/` на `/dev/sda2` 25G, занято 6.5G (28%). Раздел журналов — образ, смонтированный в `/var/log/billing` |
| Заполнение раздела журналов | `df -h /var/log/billing` | Сразу после стенда: `/dev/loop17 172M 158M 11M 94%`. Через 45 секунд, пока `billing-api` писал отладку: `158M` занято, `10M` свободно, **95%** |
| Что занимает место | `du -sh` по содержимому `/var/log/billing`, затем сортировка | 15 журналов по 7.0M за 10–24 октября; три журнала по 1.0M за 29–31 октября; `api.log` 236K и растёт; каталог `exports` 9.0M; дамп `core.billing-api.4711` 40M |
| Учётная запись billing | `id billing`, `getent passwd billing` | uid 997, gid 973(billing), оболочка `/usr/sbin/nologin`, домашний каталог `/var/lib/billing` |
| Группа billing | `getent group billing` | `billing:x:973:` |
| Процессы billing | `ps -u billing -o pid,ppid,stat,%cpu,etime,cmd` | супервизор `billingd` pid 5860; `billing-api` pid 5861; `billing-report` pid 5862 и 8 рабочих процессов |
| Нагрузка | `uptime`, `top -b -n 1` | load average **4.38**, 1.38, 0.54 при 4 ядрах. CPU: 97.8% user, 0% idle. В `top` восемь процессов `billing-report` |
| Настройки | `stat -c '%U %G %a' /etc/billing/billing.conf` | `root root 666` |
| Уровень журнала и каталог выгрузок | `grep` строк `LOG_LEVEL` и `EXPORT_DIR` в `billing.conf` | `LOG_LEVEL=debug`, `EXPORT_DIR=/var/log/billing/exports` |
| Каталоги служб | `ls -ld` | `/var/log/billing` — `billing:billing` 755; `/var/lib/billing` — `billing:billing` 750; программы в `/usr/local/bin` и `/usr/local/lib/billing` |

Дерево на момент замера:

```text
python3 billingd.py          pid 5860
├── billing-api              pid 5861
└── billing-report           pid 5862
    ├── --worker 1           pid 5867   ~50% CPU
    ├── --worker 2 … 8       pid 5868–5874
```

В конце `api.log` до любых правок были строки `level=debug sql="SELECT ..."`. Файл настроек содержит `DB_PASSWORD`; значение в паспорт не копировалось. Строка с паролем есть: `grep -c '^DB_PASSWORD='` вернуло 1.

## Что показалось неправильным

- Раздел журналов заполнен на 94–95% при пороге инцидента. Свободно было 10–11 МБ.
- Журналы с 10 по 24 октября старше 7 суток и лежат на сервере. Это видно по `find /var/log/billing -type f -mtime +7`.
- Дамп `core.billing-api.4711` (40 МБ, дата 30 октября) хранится на разделе журналов. Ему 2 дня, поэтому отбор «старше 7 дней» его не берёт.
- Выгрузка `export-2026-09.csv` (9 359 161 байт, дата 20 октября) лежит в `/var/log/billing/exports`. Это данные бухгалтерии, не журнал. Владелец `billing:billing`, режим 644.
- `LOG_LEVEL=debug`: `billing-api` пишет пачку отладочных строк примерно раз в секунду, `api.log` растёт.
- Сверка не завершилась: 8 рабочих процессов крутят пустой цикл и занимают все ядра. Средняя нагрузка 4.38 выше числа ядер.
- `/etc/billing/billing.conf` открыт всем на запись (`666`), группа `root`, внутри пароль базы.
