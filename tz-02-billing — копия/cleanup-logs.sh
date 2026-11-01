#!/bin/bash
# cleanup-logs.sh — очистка раздела журналов billing по политике хранения.
#   sudo bash cleanup-logs.sh          — только показать, что будет удалено
#   sudo bash cleanup-logs.sh --apply  — удалить
set -eu
DIR=/var/log/billing
DAYS=7
APPLY=no
[ "${1:-}" = --apply ] && APPLY=yes

[ -d "$DIR" ] || { echo "Нет каталога $DIR"; exit 1; }

echo "Раздел до очистки:"; df -h "$DIR" | tail -1

# Журналы *.log старше 7 суток и аварийные дампы core*.
# Выгрузки export-* не журналы: их не показываем и не удаляем,
# даже если файл лежит в этом каталоге или старше 7 суток.
candidates() {
  find "$DIR" -type f \
    ! -name 'export-*' \
    ! -path '*/exports/*' \
    \( -name 'core*' -o \( -name '*.log' -mtime +"$DAYS" \) \) \
    "$@"
}

echo "Будет удалено:"
candidates -ls

if [ "$APPLY" = yes ]; then
  candidates -delete
  echo "Раздел после очистки:"; df -h "$DIR" | tail -1
else
  echo "Ничего не удалено. Для удаления: sudo bash $0 --apply"
fi
