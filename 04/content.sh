#!/bin/bash

# Массивы с возможными значениями
CODES=(200 201 400 401 403 404 500 501 502 503)
METHODS=("GET" "POST" "PUT" "PATCH" "DELETE")

# Коды ответа HTTP:
# 200 - OK: запрос прошел успешно
# 201 - Created: ресурс успешно создан
# 400 - Bad Request: ошибка в запросе
# 401 - Unauthorized: требуется аутентификация
# 403 - Forbidden: доступ запрещен
# 404 - Not Found: ресурс не найден
# 500 - Internal Server Error: внутренняя ошибка сервера
# 501 - Not Implemented: метод не реализован
# 502 - Bad Gateway: неправильный ответ от вышестоящего сервера
# 503 - Service Unavailable: сервис недоступен

# Формат combined лога nginx:
# $remote_addr - - [$time_local] "$request" $status $size_body_bytes_sent "$http_referer" "$http_user_agent"

USER_AGENTS=(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:85.0) Gecko/20100101 Firefox/85.0"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/88.0.4324.96 Safari/537.36"
  "Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Safari/605.1.15"
  "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Edg/88.0.705.56"
  "Googlebot/2.1 (+http://www.google.com/bot.html)"
  "curl/7.64.1"
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/91.0.4472.124 Safari/537.36"
  "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/54.0"
  "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148"
  "Mozilla/5.0 (Android 11; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0"
  "Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/92.0.4515.107 Safari/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_16_0) AppleWebKit/537.36 Chrome/90.0.4430.212 Safari/537.36"
  "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0"
  "Opera/9.80 (Android; Opera Mini/28.0.2254/66.318; U; en) Presto/2.12.423 Version/12.16"
  "Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 Chrome/91.0.4472.120 Mobile Safari/537.36"
  "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148"
  "Mozilla/5.0 (Windows NT 6.3; Win64; x64; Trident/7.0; rv:11.0) like Gecko"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 Chrome/89.0.4389.114 Safari/537.36"
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/93.0.4577.63 Safari/537.36"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Edg/93.0.961.47"
  "Mozilla/5.0 (Android 12; SM-G998B) AppleWebKit/537.36 Chrome/94.0.4606.85 Mobile Safari/537.36"
  "Mozilla/5.0 (iPad; CPU OS 15_1 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148"
  "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 Chrome/88.0.4324.192 Safari/537.36"
  "Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:92.0) Gecko/20100101 Firefox/92.0"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/95.0.4638.54 Safari/537.36"
  "Bingbot/2.0 (+http://www.bing.com/bingbot.htm)"
  "DuckDuckBot/1.0; (+http://duckduckgo.com/duckduckbot.html)"
  "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)"
  "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)"
  "Twitterbot/1.0"
  "WhatsApp/2.21.24.21"
  "TelegramBot (like TwitterBot)"
  "Slackbot-LinkExpanding 1.0 (+https://api.slack.com/robots)"
  "Mozilla/5.0 (compatible; Discordbot/2.0; +https://discordapp.com)"
)

URLS=(
  "/"
  "/index.html"
  "/about"
  "/api/v1/users"
  "/api/v1/orders"
  "/contact"
  "/static/css/style.css"
  "/static/js/app.js"
  "/login"
  "/logout"
  "/products"
  "/products/electronics"
  "/products/books"
  "/products/clothing"
  "/cart"
  "/checkout"
  "/profile"
  "/settings"
  "/admin"
  "/admin/dashboard"
  "/admin/users"
  "/admin/products"
  "/api/v2/products"
  "/api/v2/categories"
  "/api/v2/search"
  "/api/v2/auth/login"
  "/api/v2/auth/register"
  "/blog"
  "/blog/post-1"
  "/blog/post-2"
  "/news"
  "/news/latest"
  "/faq"
  "/help"
  "/privacy-policy"
  "/terms-of-service"
  "/sitemap.xml"
  "/robots.txt"
  "/favicon.ico"
  "/images/logo.png"
  "/images/banner.jpg"
  "/downloads/app.zip"
  "/documentation"
  "/api/docs"
  "/health"
  "/status"
)

# Функция для генерации случайного IP-адреса (от 1 до 254 в каждом октете)
generate_ip() {
  echo "$((RANDOM % 254 + 1)).$((RANDOM % 254 + 1)).$((RANDOM % 254 + 1)).$((RANDOM % 254 + 1))"
}

# Функция для генерации случайного размера тела ответа (bytes sent)
generate_bytes_sent() {
  echo $((RANDOM % 5000 + 200))
}