#!/bin/bash

set -euo pipefail
export TZ='Europe/Moscow'

source ./validation.sh
source ./name_generator.sh

start_time=$(date +%s)
start_time_readable=$(date '+%H:%M:%S %d-%m-%Y')


folder_letters=$1
file_letters_and_ext=$2
file_size_param=$3

file_name="${file_letters_and_ext%%.*}"
file_extension="${file_letters_and_ext#*.}"


init_log_file

# Запускаем проверки
validate_parameters "$folder_letters" "$file_letters_and_ext" "$file_size_param"

# Считываем размер файла
if [[ "$file_size_param" =~ ^([1-9][0-9]?)[Mm][Bb]$ ]]; then
  file_size="${BASH_REMATCH[1]}"
fi

echo "Parameters validation passed" >> "$log_file"

get_valid_dirs
create_trash "$folder_letters" "$file_name" "$file_extension" "$file_size"
print_execution_stats "$start_time" "$start_time_readable"