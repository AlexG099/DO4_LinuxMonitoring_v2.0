#!/bin/bash

# Проверка, что передано нужное количество аргументов
CHECK_ARGS() {
  local argc=$1
  if [[ "$argc" -lt 1 ]]; then
    echo -e "\033[31mError: missing required parameter\033[0m"
    echo "Usage: $0 {1|2|3}"
    exit 1
  fi
}

# Проверка, что переданный параметр - целое число
IS_DIGIT() {
  local val="$1"
  if ! [[ "$val" =~ ^[0-9]+$ ]]; then
    echo -e "\033[31mError: parameter must be a number\033[0m"
    exit 1
  fi
}

# Проверка существования и доступности файла
CHECK_FILE() {
  local file_path="$1"
  if [[ ! -f "$file_path" ]]; then
    echo -e "\033[31mError: file $file_path not found\033[0m"
    exit 1
  fi
  if [[ ! -r "$file_path" ]]; then
    echo -e "\033[31mError: file $file_path is not readable\033[0m"
    exit 1
  fi
}

# Проверка корректности формата даты-времени
CHECK_DATE_TIME() {
  local datetime="$1"
  
  if ! [[ "$datetime" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ ([0-9]{2}):([0-9]{2})$ ]]; then
    echo -e "\033[31mError: incorrect date-time format. Expected YYYY-MM-DD HH:MM\033[0m"
    exit 1
  fi
}