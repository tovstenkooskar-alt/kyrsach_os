#!/bin/bash
# disk-watch.sh КАТАЛОГ ПОРОГ
# Печатает заполнение раздела каталога и пять самых больших файлов.
# Код 1, если заполнение строго выше порога (в процентах).
set -eu
DIR=${1:?нужен каталог}
THRESHOLD=${2:?нужен порог в процентах}
case "$THRESHOLD" in
  ''|*[!0-9]*) echo "Порог должен быть целым числом процентов" >&2; exit 2 ;;
esac
[ -d "$DIR" ] || { echo "Нет каталога $DIR" >&2; exit 2; }

pct=$(df --output=pcent "$DIR" | tail -1 | tr -dc '0-9')
echo "Каталог: $DIR"
echo "Заполнение раздела: ${pct}%"
echo "Пять самых больших файлов:"
find "$DIR" -type f -printf '%s\t%p\n' | sort -nr | head -5 | awk -F'\t' '{printf "%10d  %s\n", $1, $2}'

if [ "$pct" -gt "$THRESHOLD" ]; then
  echo "Выше порога ${THRESHOLD}%"
  exit 1
fi
echo "Не выше порога ${THRESHOLD}%"
exit 0
