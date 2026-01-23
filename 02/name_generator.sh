#!/bin/bash

set -euo pipefail

declare -a valid_dirs
log_file=""

init_log_file() {
  log_file="$PWD/file_logs.txt"
  : > "$log_file" || { echo "Cannot write to log file $log_file"; exit 1; }
  echo "Logging to $log_file" >&2
}


get_valid_dirs() {
  local dirs=()
  local root_dir="/home"

  while IFS= read -r dir; do
    
    if [[ "$dir" != *bin* ]] && [[ "$dir" != *sbin* ]] && [[ "$dir" != *run* ]] && [[ "$dir" != *sys* ]] && [[ "$dir" != *proc* ]]; then
      dirs+=("$dir")
    fi
  done < <(find "$root_dir" -type d -writable 2>/dev/null)

  if [ "${#dirs[@]}" -eq 0 ]; then
    echo "ERROR: No writable directories found under $root_dir excluding bin/sbin/run/sys/proc" >&2
    return 1
  fi

  valid_dirs=("${dirs[@]}")
  return 0
}

generate_name() {
  local base_name=$1
  local step=$2
  local length=${#base_name}
  local min_length=5
  local name_length=$((min_length + step))
  local result=""
  local remaining=$name_length
  local block_lengths=()

  # Инициализируем массив с длинами блоков по 1 для каждого символа
  for ((i=0; i<length; i++)); do
    block_lengths[i]=1
  done

  # Вычитаем уже использованные длины
  local used_length=$length
  local extra=$((name_length - used_length))

  # Распределяем оставшиеся дополнительные символы: добавляем по 1 к блокам в порядке символов пока extra > 0
  local idx=0
  while (( extra > 0 )); do
    block_lengths[idx]=$((block_lengths[idx] + 1))
    ((extra--))
    idx=$(((idx + 1) % length))
  done

  # Собираем имя из последовательных блоков
  for (( i=0; i<length; i++ )); do
    local char="${base_name:i:1}"
    for (( r=0; r<block_lengths[i]; r++ )); do
      result+=$char
    done
  done

  echo "$result"
}

create_trash() {
  local folder_letters=$1
  local file_name=$2
  local file_extension=$3
  local file_size=$4
  local max_folders=100
  local folders_created=0
  local script_date
  script_date=$(date '+%d%m%y')

  # Проверяем что массив valid_dirs не пуст
  if [ "${#valid_dirs[@]}" -eq 0 ]; then
    echo "ERROR: No valid base directories available" >&2
    exit 1
  fi

  while (( folders_created < max_folders )); do
    # Выбираем случайную директорию из массива valid_dirs
    local base_dir="${valid_dirs[RANDOM % ${#valid_dirs[@]}]}"

    # Проверяем что директория существует и доступна для записи
    if [ ! -d "$base_dir" ] || [ ! -w "$base_dir" ]; then
      echo "WARNING: Base directory $base_dir does not exist or is not writable. Skipping."
      continue
    fi

    local free_mb
    free_mb=$(check_free_space_mb "$base_dir")
    if (( free_mb < 1000 )); then
      echo -e "\033[31mLess than 1000MB free space left in $base_dir! Stopping.\033[0m"
      break
    fi

    folders_created=$((folders_created + 1))

    # Генерируем имя директории 
    local folder_name
    folder_name=$(generate_name "$folder_letters" $((folders_created - 1)))
    folder_name="${folder_name}_${script_date}"

    local folder_full_path="${base_dir}/${folder_name}"

    # Создаем директорию с уже сгенерированным именем
    mkdir -p "$folder_full_path"
    if [ $? -ne 0 ]; then
      echo "ERROR: Failed to create folder $folder_full_path" >&2
      exit 1
    fi

    # Создаем запись в логах
    {
      echo "PATH: $folder_full_path"
      echo "DATE: $(date '+%H:%M:%S %d-%m-%Y %Z')"
      echo "TYPE: directory"
      echo ""
    } >> "$log_file"

    # Перемещаемся в созданную директорию
    cd "$folder_full_path" || { echo "ERROR: Failed to cd into $folder_full_path"; exit 1; }

    local files_to_create=$(( RANDOM % 100 + 10 ))

    for (( f=0; f<files_to_create; f++ )); do
      free_mb=$(check_free_space_mb "$folder_full_path")
      if (( free_mb < 1000 )); then
        echo -e "\033[31mLess than 1000MB free space left! Stopping file creation.\033[0m"
        cd "$base_dir" || exit 1
        return
      fi

      local file_generated_name
      file_generated_name=$(generate_name "$file_name" "$f")
      local full_file_name="${file_generated_name}_${script_date}.${file_extension}"

      if ! dd if=/dev/zero of="$full_file_name" bs=1M count="$file_size" status=none; then
        echo "ERROR: Failed to create file $full_file_name" >&2
        cd "$base_dir" || exit 1
        exit 1
      fi

      local abs_path="${folder_full_path}/${full_file_name}"

      {
        echo "PATH: $abs_path"
        echo "DATE: $(date '+%H:%M:%S %d-%m-%Y %Z')"
        echo "TYPE: file"
        echo "SIZE: $file_size Mb"
        echo ""
      } >> "$log_file"
    done
    # Возвращаемся в исходную директорию
    cd "$base_dir" || { echo "ERROR: Failed to cd back to $base_dir"; exit 1; }
  done
}

print_execution_stats() {
  local start_time=$1
  local start_time_readable=$2
  
  local end_time
  end_time=$(date +%s)
  local end_time_readable
  end_time_readable=$(date '+%H:%M:%S %d-%m-%Y')
  local duration=$((end_time - start_time))
  local duration_hms
  duration_hms=$(printf '%02d:%02d:%02d' $((duration/3600)) $(((duration%3600)/60)) $((duration%60)))

  echo -e "\nScript started at: $start_time_readable"
  echo "Script finished at: $end_time_readable"
  echo "Total time: $duration_hms"

  {
    echo "Script started at: $start_time_readable"
    echo "Script finished at: $end_time_readable"
    echo "Total runtime: $duration_hms"
    echo ""
  } >> "$log_file"
}