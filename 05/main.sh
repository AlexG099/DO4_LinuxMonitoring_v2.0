#!/bin/bash

source ./validation.sh

case $1 in
    1)
        # awk '{print $9 " " $0}' "$LOG_DIR"/nginx_log_*.log | sort -n | cut -d' ' -f2- > "output_1.txt"
        awk '{print $9 " " NR " " $0}' "$LOG_DIR"/nginx_log_*.log | sort -k1,1n -k2,2n | cut -d' ' -f3- > "output_1.txt"
        echo "Результат сохранен в output_1.txt"
        ;;
    2)
        # awk '{print $1}' "$LOG_DIR"/nginx_log_*.log | sort -u > "output_2.txt"
        awk '{if (!($1 in seen)) {print $1; seen[$1]++}}' "$LOG_DIR"/nginx_log_*.log > "output_2.txt"
        echo "Результат сохранен в output_2.txt"
        ;;
    3)
        awk '$9 ~ /^[45][0-9][0-9]$/' "$LOG_DIR"/nginx_log_*.log > "output_3.txt"
        echo "Результат сохранен в output_3.txt"
        ;;
    4)
        # awk '$9 ~ /^[45][0-9][0-9]$/ {print $1}' "$LOG_DIR"/nginx_log_*.log | sort -u
        awk '$9 ~ /^[45][0-9][0-9]$/ {if (!($1 in seen)) {print $1; seen[$1]++}}' "$LOG_DIR"/nginx_log_*.log > "output_4.txt"
        echo "Результат сохранен в output_4.txt"
        ;;
    *)
        echo "Неверный параметр: $1"
        echo "Допустимые значения: 1, 2, 3, 4"
        exit 1
        ;;
esac