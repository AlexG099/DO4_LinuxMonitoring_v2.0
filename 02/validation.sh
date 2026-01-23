#!/bin/bash

set -euo pipefail

# Проверка переданных параметров
validate_parameters() {
  local folder_letters=$1
  local file_letters_and_ext=$2
  local file_size_param=$3
  
  local file_name="${file_letters_and_ext%%.*}"
  local file_extension="${file_letters_and_ext#*.}"
  
  local folder_letters_len=${#folder_letters}
  local file_name_len=${#file_name}
  local file_extension_len=${#file_extension}

  # Проверяем количество параметров
  if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <folder_letters> <file_letters_and_ext> <file_size_MB>"
    echo "Example: $0 az az.az 3Mb"
    exit 1
  fi

  # Проверяем значение и формат размера файла
  if [[ "$file_size_param" =~ ^([1-9][0-9]?)[Mm][Bb]$ ]]; then
    local file_size="${BASH_REMATCH[1]}"
    if (( file_size > 100 )); then
      echo "File size must be not more than 100Mb"
      exit 1
    fi
  else
    echo "File size parameter must be in format like 3Mb"
    exit 1
  fi

  # Проверяем что в текущей директории есть права на запись
  if [ ! -w "$PWD" ]; then
    echo "No write permission in current directory $PWD"
    exit 1
  fi

  # Проверяем длину имени директории
  if [ "$folder_letters_len" -gt 7 ] || [ "$file_name_len" -gt 7 ] || [ "$file_extension_len" -gt 3 ]; then
    echo "Folder name and file name must be not more than 7 letters; extension max 3 letters"
    exit 1
  fi

  # Проверяем, что исподбзованы только латинские символы
  if [[ ! "$folder_letters" =~ ^[A-Za-z]+$ ]] || [[ ! "$file_name" =~ ^[A-Za-z]+$ ]] || [[ ! "$file_extension" =~ ^[A-Za-z]+$ ]]; then
    echo "Use only English letters in folder name, file name and file extension"
    exit 1
  fi
}

check_free_space_mb() {
  local path=${1:-$PWD}
  df --output=avail -BM "$path" | tail -n1 | tr -d 'M' || echo 0
}