#!/bin/bash

set -euo pipefail

# Проверка что скрипт запускается без параметров
if [ $# -ne 0 ]; then
    echo "ОШИБКА: Этот скрипт не принимает параметры" >&2
    echo "Использование: $0" >&2
    exit 1
fi

# Проверка что установлен goaccess
if ! command -v goaccess &> /dev/null; then
    echo "ОШИБКА: GoAccess не установлен" >&2
    echo "Установите GoAccess: sudo apt install goaccess" >&2
    exit 1
fi

# Проверка что установлен python3
if ! command -v python3 &> /dev/null; then
    echo "ОШИБКА: Python3 не установлен" >&2
    echo "Установите Python3: sudo apt install python3" >&2
    exit 1
fi

LOG_DIR="../04/nginx_logs"
REPORT_FILE="report_6.html"

# Проверка существования директории с логами
if [ ! -d "$LOG_DIR" ]; then
    echo "ОШИБКА: Директория с логами $LOG_DIR не найдена!" >&2
    exit 1
fi

# Проверка существования лог-файлов
if ! ls "$LOG_DIR"/*.log >/dev/null 2>&1; then
    echo "ОШИБКА: Лог-файлы не найдены в директории $LOG_DIR" >&2
    echo "Убедитесь что файлы имеют расширение .log" >&2
    exit 1
fi

# Проверка что лог-файлы не пустые
for log_file in "$LOG_DIR"/*.log; do
    if [ ! -s "$log_file" ]; then
        echo "ОШИБКА: Лог-файл $log_file пустой!" >&2
        exit 1
    fi
done