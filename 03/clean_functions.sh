#!/bin/bash

log_file="../02/file_logs.txt"

# Функция для вывода свободного места на корневом разделе
show_free_space() {
  df -h / | awk 'NR==2 {print $4}'
}

# Получение массива путей из лога
get_paths_from_log() {
  grep '^PATH: ' "$log_file" | sed 's/^PATH: //' | sed 's/[[:space:]]*$//'
}

function CLEAN_BY_LOG() {
  CHECK_FILE "$log_file"
  echo -e "\033[33mFree space before cleanup: $(show_free_space)\033[0m"
  while IFS= read -r path; do
    if [[ -e "$path" ]]; then
      rm -rf "$path"
    fi
  done < <(get_paths_from_log)

  echo -e "\033[36mCleaning done...\033[0m"
  echo -e "\033[33mFree space after cleanup: $(show_free_space)\033[0m"
}

function CLEAN_BY_DATE() {
  CHECK_FILE "$log_file"
  echo -e "\033[33mFree space before cleanup: $(show_free_space)\033[0m"

  echo -e "\033[35mEnter start time in format (YYYY-MM-DD HH:MM):\033[0m"
  read -r start
  CHECK_DATE_TIME "$start"

  echo -e "\033[35mEnter end time in format (YYYY-MM-DD HH:MM):\033[0m"
  read -r end
  CHECK_DATE_TIME "$end"

  echo "Searching for files created between $start and $end..."

  # Находим файлы созданные в указанном интервале, исключая системные пути
  files=$(find / -type f -newermt "$start" ! -newermt "$end" 2>/dev/null | \
          grep -v -e "/bin/" -e "/sbin/" -e "/run/" -e "/sys/" -e "/proc/" -e "/02/src/")

  # Находим папки созданные в указанном интервале, исключая системные пути
  directories=$(find / -type d -newermt "$start" ! -newermt "$end" 2>/dev/null | \
               grep -v -e "/bin/" -e "/sbin/" -e "/run/" -e "/sys/" -e "/proc/" -e "/02/src/" -e "^/$")

  # Удаляем только те файлы и папки, которые есть в логе
  while IFS= read -r path; do
    path=$(echo "$path" | sed 's/[[:space:]]*$//')
    # Проверяем файлы
    if echo "$files" | grep -q "^$path$"; then
      # echo "Deleting file: $path"
      rm -rf "$path"
    fi
    # Проверяем директории
    if echo "$directories" | grep -q "^$path$"; then
      # echo "Deleting directory: $path"
      rm -rf "$path"
    fi
  done < <(get_paths_from_log)

  echo -e "\033[36mCleaning done...\033[0m"
  echo -e "\033[33mFree space after cleanup: $(show_free_space)\033[0m"
}

function CLEAN_BY_MASK() {
  echo -e "\033[33mFree space: $(show_free_space)\033[0m"

  read -p "Enter characters for mask (e.g., 'az'): " chars
  [[ ! "$chars" =~ ^[a-zA-Z]+$ ]] && echo -e "\033[31mError: Only letters allowed\033[0m" && return 1

  read -p "Enter date (6 digits): " date
  [[ ! "$date" =~ ^[0-9]{6}$ ]] && echo -e "\033[31mError: Date must be 6 digits\033[0m" && return 1

  echo "Searching for files and directories matching mask '$chars' and date '$date'..."

  # Находим файлы по маске, исключая системные пути
  files=$(find / -type f -name "*_${date}" 2>/dev/null | \
          grep -v -e "/bin/" -e "/sbin/" -e "/run/" -e "/sys/" -e "/proc/" -e "/02/src/")

  # Находим папки по маске, исключая системные пути
  directories=$(find / -type d -name "*_${date}" 2>/dev/null | \
               grep -v -e "/bin/" -e "/sbin/" -e "/run/" -e "/sys/" -e "/proc/" -e "/02/src/" -e "^/$")

  # Объединяем файлы и директории
  items=()
  while IFS= read -r item; do [[ -n "$item" ]] && items+=("$item"); done <<< "$files"
  while IFS= read -r item; do [[ -n "$item" ]] && items+=("$item"); done <<< "$directories"

  # Фильтруем по маске символов
  filtered_items=()
  for item in "${items[@]}"; do
    name=$(basename "$item")
    base="${name%_${date}}"
    if [[ ${#base} -ge 4 && "$base" =~ ^[${chars}]+$ ]]; then
      # Проверяем что все символы маски присутствуют
      valid=1
      for ((i=0; i<${#chars}; i++)); do
        [[ "$base" != *"${chars:i:1}"* ]] && valid=0
      done
      [[ $valid -eq 1 ]] && filtered_items+=("$item")
    fi
  done

  [[ ${#filtered_items[@]} -eq 0 ]] && echo -e "\033[34mNo items found\033[0m" && return 0

  # echo -e "\033[31mFound ${#filtered_items[@]} items:\033[0m"
  # printf '  %s\n' "${filtered_items[@]}"
  
  for item in "${filtered_items[@]}"; do
    # echo "Deleting: $item"
    rm -rf "$item"
  done

  # echo -e "\033[36mDone. Removed ${#filtered_items[@]} items.\033[0m"
  echo -e "\033[33mFree space: $(show_free_space)\033[0m"
}