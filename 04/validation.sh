#!/bin/bash

set -euo pipefail
# Проверка что скрипт запускается без параметров
if [ $# -ne 0 ]; then
    echo "ОШИБКА: Этот скрипт не принимает параметры" >&2
    echo "Использование: $0" >&2
    exit 1
fi

# Функция проверки и создания директории
check_and_create_dir() {
    if [ ! -d "$LOG_DIR" ]; then
        if ! mkdir -p "$LOG_DIR"; then
            echo "ОШИБКА: Не удалось создать директорию $LOG_DIR" >&2
            exit 1
        fi
    fi
    
    if [ ! -w "$LOG_DIR" ]; then
        echo "ОШИБКА: Нет прав на запись в директорию $LOG_DIR" >&2
        exit 1
    fi
}

# Функция проверки доступности команды date
check_date_command() {
    if ! command -v date &> /dev/null; then
        echo "ОШИБКА: Команда 'date' не найдена" >&2
        exit 1
    fi
}

# Функция проверки корректности сгенерированного IP
validate_ip() {
    local ip="$1"
    if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    
    # Проверяем что каждый октет от 1 до 254
    local IFS='.'
    read -ra octets <<< "$ip"
    for octet in "${octets[@]}"; do
        if [[ "$octet" -lt 1 || "$octet" -gt 254 ]]; then
            return 1
        fi
    done
    return 0
}

# Функция проверки записи в файл
check_file_write() {
    local file="$1"
    if ! touch "$file" 2>/dev/null; then
        echo "ОШИБКА: Не удалось создать/записать файл $file" >&2
        return 1
    fi
    return 0
}