# Полезные PromQL запросы для мониторинга

## 📊 Основные метрики приложения

### CPU Usage
```promql
# CPU usage в процентах
rate(process_cpu_seconds_total{job="rails"}[5m]) * 100

# CPU usage за последний час
rate(process_cpu_seconds_total{job="rails"}[1h]) * 100
```

### Memory Usage
```promql
# Memory в мегабайтах
process_resident_memory_bytes{job="rails"} / 1024 / 1024

# Memory в гигабайтах
process_resident_memory_bytes{job="rails"} / 1024 / 1024 / 1024

# Virtual memory
process_virtual_memory_bytes{job="rails"} / 1024 / 1024
```

### HTTP Requests
```promql
# Requests per second (общий)
rate(http_requests_total{job="rails"}[5m])

# Requests per second по методам
sum by (method) (rate(http_requests_total{job="rails"}[5m]))

# Requests per second по путям
sum by (path) (rate(http_requests_total{job="rails"}[5m]))

# Requests per second по статус кодам
sum by (status) (rate(http_requests_total{job="rails"}[5m]))
```

### Request Duration
```promql
# Среднее время ответа в миллисекундах
rate(http_request_duration_seconds_sum{job="rails"}[5m]) / rate(http_request_duration_seconds_count{job="rails"}[5m]) * 1000

# 95-й перцентиль времени ответа
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="rails"}[5m])) * 1000

# 99-й перцентиль времени ответа
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{job="rails"}[5m])) * 1000
```

## 🔄 Sidekiq метрики

### Queue Size
```promql
# Размер очереди по имени
sidekiq_queue_size{job="sidekiq"}

# Общий размер всех очередей
sum(sidekiq_queue_size{job="sidekiq"})

# Топ-3 самых больших очередей
topk(3, sidekiq_queue_size{job="sidekiq"})
```

### Job Processing
```promql
# Jobs per second
rate(sidekiq_jobs_total{job="sidekiq"}[5m])

# Среднее время выполнения job
rate(sidekiq_job_duration_seconds_sum{job="sidekiq"}[5m]) / rate(sidekiq_job_duration_seconds_count{job="sidekiq"}[5m])

# Failed jobs per second
rate(sidekiq_failed_jobs_total{job="sidekiq"}[5m])
```

## 💾 Database метрики

### Query Performance
```promql
# Среднее время выполнения запроса в миллисекундах
rate(active_record_query_duration_seconds_sum[5m]) / rate(active_record_query_duration_seconds_count[5m]) * 1000

# Количество запросов в секунду
rate(active_record_query_duration_seconds_count[5m])

# Медленные запросы (>100ms)
active_record_query_duration_seconds > 0.1
```

### Database Connections
```promql
# Активные соединения
active_record_connection_pool_connections

# Ожидающие соединения
active_record_connection_pool_waiting
```

## 🎯 Алерты (примеры условий)

### High CPU Usage
```promql
# CPU > 80% более 5 минут
rate(process_cpu_seconds_total{job="rails"}[5m]) * 100 > 80
```

### High Memory Usage
```promql
# Memory > 800 MB
process_resident_memory_bytes{job="rails"} / 1024 / 1024 > 800
```

### Slow Requests
```promql
# Среднее время ответа > 500ms
rate(http_request_duration_seconds_sum{job="rails"}[5m]) / rate(http_request_duration_seconds_count{job="rails"}[5m]) * 1000 > 500
```

### Large Sidekiq Queue
```promql
# Очередь > 100 задач
sidekiq_queue_size{job="sidekiq"} > 100
```

### High Error Rate
```promql
# Ошибки 5xx > 1% от всех запросов
sum(rate(http_requests_total{job="rails",status=~"5.."}[5m])) / sum(rate(http_requests_total{job="rails"}[5m])) > 0.01
```

### Application Down
```promql
# Приложение не отвечает
up{job="rails"} == 0
```

## 📈 Тренды и сравнения

### CPU Usage - сравнение с прошлой неделей
```promql
# Текущая неделя
rate(process_cpu_seconds_total{job="rails"}[5m]) * 100

# Прошлая неделя
rate(process_cpu_seconds_total{job="rails"}[5m] offset 7d) * 100
```

### Request Rate - рост за последний час
```promql
# Процент роста
(rate(http_requests_total{job="rails"}[5m]) - rate(http_requests_total{job="rails"}[5m] offset 1h)) / rate(http_requests_total{job="rails"}[5m] offset 1h) * 100
```

### Peak Hours
```promql
# Максимальный RPS за последние 24 часа
max_over_time(rate(http_requests_total{job="rails"}[5m])[24h:])
```

## 🔍 Debugging запросы

### Top Slowest Endpoints
```promql
# Топ-5 самых медленных эндпоинтов
topk(5, rate(http_request_duration_seconds_sum{job="rails"}[5m]) / rate(http_request_duration_seconds_count{job="rails"}[5m]))
```

### Most Requested Endpoints
```promql
# Топ-5 самых запрашиваемых эндпоинтов
topk(5, rate(http_requests_total{job="rails"}[5m]))
```

### Error Rate by Endpoint
```promql
# Процент ошибок по эндпоинтам
sum by (path) (rate(http_requests_total{job="rails",status=~"5.."}[5m])) / sum by (path) (rate(http_requests_total{job="rails"}[5m])) * 100
```

### Memory Leak Detection
```promql
# Рост памяти за последние 24 часа (MB)
(process_resident_memory_bytes{job="rails"} - process_resident_memory_bytes{job="rails"} offset 24h) / 1024 / 1024
```

## 📊 Capacity Planning

### Average Daily Traffic
```promql
# Средний RPS за последние 7 дней
avg_over_time(rate(http_requests_total{job="rails"}[5m])[7d:])
```

### Peak Traffic
```promql
# Пиковый RPS за последние 30 дней
max_over_time(rate(http_requests_total{job="rails"}[5m])[30d:])
```

### Resource Utilization
```promql
# Процент использования CPU лимита (2 cores = 200%)
rate(process_cpu_seconds_total{job="rails"}[5m]) * 100 / 200 * 100

# Процент использования Memory лимита (1024 MB)
process_resident_memory_bytes{job="rails"} / 1024 / 1024 / 1024 * 100
```

## 💡 Полезные функции PromQL

### Агрегация
```promql
sum()      # Сумма
avg()      # Среднее
min()      # Минимум
max()      # Максимум
count()    # Количество
```

### Временные функции
```promql
rate()              # Скорость изменения (per second)
irate()             # Мгновенная скорость
increase()          # Увеличение за период
delta()             # Разница между первым и последним значением
```

### Статистика
```promql
histogram_quantile()    # Перцентили
topk()                  # Топ N значений
bottomk()               # Нижние N значений
```

### Временные окна
```promql
[5m]        # Последние 5 минут
[1h]        # Последний час
[1d]        # Последний день
offset 1h   # Сдвиг на 1 час назад
```

## 🎓 Примеры использования в Grafana

### Создание панели с алертом
1. Добавить панель
2. Вставить PromQL запрос
3. В разделе Alert создать правило
4. Настроить условие и notification channel

### Шаблонные переменные
```promql
# Создать переменную $instance
label_values(process_cpu_seconds_total, instance)

# Использовать в запросе
rate(process_cpu_seconds_total{instance="$instance"}[5m])
```

### Аннотации
```promql
# Отметить деплои на графике
changes(process_start_time_seconds{job="rails"}[5m]) > 0
```

---

**Совет:** Используйте Prometheus UI (http://90.156.228.95:9090) для тестирования запросов перед добавлением в Grafana.
