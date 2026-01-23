#!/usr/bin/env bash

export TZ='Europe/Moscow'
# Подключаем модули
source validation.sh
source clean_functions.sh

# Проверка, что логфайл существует

CHECK_ARGS "$#"
IS_DIGIT "$1"

case "$1" in
  1)
    CLEAN_BY_LOG
    ;;
  2)
    CLEAN_BY_DATE
    ;;
  3)
    CLEAN_BY_MASK
    ;;
  *)
    echo -e "\033[31mUnknown parameter value\033[0m"
    exit 1
    ;;
esac