#!/bin/sh
#--------------------------------------------------------------
# CNM database connections monitor
# Using lsof:
# lsof -U 2>/dev/null | grep -E 'mysqld\.sock' | awk '{print $1, $2}' | sort | uniq -c | sort -rn | head
#--------------------------------------------------------------
while true; do
  CR=$(ps -eo args= -ww | sed 's/^\[//; s/\]$//' | grep -c '^crawler')
  NO=$(ps -eo args= -ww | sed 's/^\[//; s/\]$//' | grep -c '^notificationsd')
  AC=$(ps -eo args= -ww | sed 's/^\[//; s/\]$//' | grep -c '^actionsd')
  AP=$(ps -eo args= -ww  | grep -c 'apache2')
  CX=$(mysql -N -B -e "SELECT COUNT(*) FROM information_schema.PROCESSLIST WHERE user='onm'")
  SL=$(mysql -N -B -e "SELECT COUNT(*) FROM information_schema.PROCESSLIST WHERE user='onm' AND command='Sleep' AND time>300")
  printf "%s  crawler=%-4s notif=%-3s act=%-3s apache=%-3s | conexiones=%-4s dormidas>5m=%s\n" \
         "$(date +%T)" "$CR" "$NO" "$AC" "$AP" "$CX" "$SL"
  sleep 30
done
