# Part 6. **GoAccess**

С помощью утилиты GoAccess получим ту же информацию, что и в части 5

Установим утилиту GoAccess: `sudo apt install goaccess`  
Используя логи из задания 4 сгенерируем отчет командой: `goaccess "$LOG_DIR"/*.log -o "$REPORT_FILE" --log-format=COMBINED`  
Запустим веб-сервер для просмотра отчета с локальной машины по адресу: `http://localhost:8000`  

### Вывод отчета
![screen](images/6.1.PNG)  
![screen](images/6.2.PNG)  
![screen](images/6.3.PNG)  
![screen](images/6.4.PNG)  
![screen](images/6.5.PNG)
