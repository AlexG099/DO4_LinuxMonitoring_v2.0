#!/bin/bash

source ./validation.sh
source ./content.sh

LOG_DIR="./nginx_logs"
mkdir -p "$LOG_DIR"

# Текущая дата 
START_DATE=$(date +%Y-%m-%d)

for day_offset in {0..4}; do
  # Дата для текущего лога в формате YYYY-MM-DD
  LOG_DAY=$(date -d "$START_DATE - $day_offset days" +%Y-%m-%d)
  # Имя файла, например nginx_log_2025-08-12.log
  LOG_FILE="$LOG_DIR/nginx_log_${LOG_DAY}.log"

  # Кол-во записей от 100 до 1000
  NUM_RECORDS=$((RANDOM % 901 + 100))

  # Начальное время в секундах с 00:00:00
  SECONDS_IN_DAY=86400
  CURRENT_SECOND=0
  # Средний шаг между записями, так чтобы все записей разместить в дневном интервале
  STEP=$((SECONDS_IN_DAY / NUM_RECORDS))
  [ $STEP -eq 0 ] && STEP=1

  > "$LOG_FILE"  # очистка файла

  for ((i=0; i<NUM_RECORDS; i++)); do
    IP=$(generate_ip)
    CODE=${CODES[$RANDOM % ${#CODES[@]}]}
    METHOD=${METHODS[$RANDOM % ${#METHODS[@]}]}
    USER_AGENT=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
    URL=${URLS[$RANDOM % ${#URLS[@]}]}
    BYTES_SENT=$(generate_bytes_sent)
    
    # Время запроса
    LOG_TIME=$(date -d "$LOG_DAY + $CURRENT_SECOND seconds" +"%d/%b/%Y:%H:%M:%S %z")

    # Формируем строку запроса: "METHOD URL HTTP/1.1"
    REQUEST="\"$METHOD $URL HTTP/1.1\""

    # Случайный рефер (40% шанс что будет "-")
    if (( RANDOM % 10 < 6 )); then
      REFERER="-"
    else
      # можно подставить фиктивный реферер случайно из URLS или просто example.com
      REFERER="\"http://example.com${URL}\""
    fi

    # Запись в файл
    # Формат: IP - - [DATE] "METHOD URL HTTP/1.1" STATUS BYTES REFERER USER_AGENT
    echo "$IP - - [$LOG_TIME] $REQUEST $CODE $BYTES_SENT $REFERER \"$USER_AGENT\"" >> "$LOG_FILE"

    # Увеличиваем время запроса
    CURRENT_SECOND=$((CURRENT_SECOND + STEP))
  done

  echo "Создан файл $LOG_FILE с $NUM_RECORDS записями"
done
