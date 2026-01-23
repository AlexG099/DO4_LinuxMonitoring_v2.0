#!/bin/bash

source ./validation.sh

echo "Проверки пройдены успешно"
echo "Генерация HTML отчета для веб-интерфейса..."

# Генерация HTML отчета для веб-интерфейса:
goaccess "$LOG_DIR"/*.log -o "$REPORT_FILE" --log-format=COMBINED

if [ $? -eq 0 ] && [ -f "$REPORT_FILE" ]; then
    echo "Отчет успешно создан: $REPORT_FILE"
else
    echo "ОШИБКА: Не удалось создать отчет $REPORT_FILE" >&2
    exit 1
fi

echo "Запуск веб-сервера для просмотра на http://localhost:8000"
echo "Для остановки нажмите Ctrl+C"

# Запуск веб-сервера для просмотра
python3 -m http.server 8000