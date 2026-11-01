#!/bin/bash
# snapshot.sh ПОЛЬЗОВАТЕЛЬ
# Снимок состояния инцидента: uptime, df -h, top и дерево процессов.
set -eu
USER_NAME=${1:?нужен пользователь}
OUT="snapshot-$(date +%Y%m%d-%H%M%S).txt"
{
  echo "=== date ==="
  date '+%F %T %Z'
  echo "=== uptime ==="
  uptime
  echo "=== df -h ==="
  df -h
  echo "=== top -b -n 1 ==="
  top -b -n 1
  echo "=== process tree: $USER_NAME ==="
  if command -v pstree >/dev/null 2>&1; then
    pstree -p -s -u "$USER_NAME" || ps -u "$USER_NAME" -o pid,ppid,stat,etime,cmd
  else
    ps -u "$USER_NAME" -o pid,ppid,stat,etime,%cpu,cmd
  fi
} > "$OUT"
echo "Сохранено: $OUT"
