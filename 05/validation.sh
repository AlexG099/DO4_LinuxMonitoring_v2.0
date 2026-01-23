#!/bin/bash

LOG_DIR="../04/nginx_logs"
LOG_FILES="$LOG_DIR/nginx_log_*.log"

if [ $# -ne 1 ]; then
    echo "Использование: $0 <номер_задания>"
    echo "1 - Все записи, отсортированные по коду ответа"
    echo "2 - Все уникальные IP, встречающиеся в записях"
    echo "3 - Все запросы с ошибками (код ответа — 4хх или 5хх)"
    echo "4 - Все уникальные IP, которые встречаются среди ошибочных запросов"
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Директория с логами $LOG_DIR не найдена!"
    exit 1
fi

if ! ls $LOG_FILES >/dev/null 2>&1; then
    echo "Файлы логов не найдены в директории $LOG_DIR"
    exit 1
fi
