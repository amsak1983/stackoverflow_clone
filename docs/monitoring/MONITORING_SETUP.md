# Production Monitoring Setup Guide

## Обзор

Система мониторинга состоит из:
- **Prometheus** - сбор и хранение метрик (порт 9090)
- **Grafana** - визуализация метрик (порт 3001)
- **prometheus_exporter** - экспорт метрик из Rails (порт 9394)

## Развертывание

### 1. Установка зависимостей

```bash
bundle install
```

### 2. Деплой через Kamal

```bash
# Деплой основного приложения с обновленными настройками
kamal deploy

# Деплой Prometheus
kamal accessory boot prometheus

# Деплой Grafana
kamal accessory boot grafana
```

### 3. Проверка работы

**Проверить статус всех сервисов:**
```bash
kamal app details
kamal accessory details prometheus
kamal accessory details grafana
```

**Проверить healthcheck:**
```bash
curl http://90.156.228.95:3000/up
```

**Проверить метрики:**
```bash
curl http://90.156.228.95:9394/metrics
```

## Доступ к интерфейсам

### Prometheus
- **URL:** http://90.156.228.95:9090
- **Аутентификация:** Не требуется (рекомендуется настроить firewall)

Полезные запросы в Prometheus:
```promql
# CPU usage
rate(process_cpu_seconds_total{job="rails"}[5m]) * 100

# Memory usage
process_resident_memory_bytes{job="rails"} / 1024 / 1024

# Request rate
rate(http_requests_total{job="rails"}[5m])

# Sidekiq queue size
sidekiq_queue_size
```

### Grafana
- **URL:** http://90.156.228.95:3001
- **Username:** admin
- **Password:** admin (измените при первом входе!)

## Настройка Grafana

### 1. Добавить Prometheus как Data Source

1. Войдите в Grafana: http://90.156.228.95:3001
2. Перейдите в **Configuration → Data Sources**
3. Нажмите **Add data source**
4. Выберите **Prometheus**
5. Настройте:
   - **URL:** `http://localhost:9090` (т.к. используется `network: host`)
   - **Access:** Server (default)
6. Нажмите **Save & Test**

### 2. Импортировать Dashboard

**Вариант A: Автоматический импорт (рекомендуется)**

```bash
# Скопируйте dashboard в контейнер Grafana
docker cp config/grafana-dashboard.json stackoverflow_clone-grafana:/tmp/

# Импортируйте через API
curl -X POST http://admin:admin@90.156.228.95:3001/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @config/grafana-dashboard.json
```

**Вариант B: Ручной импорт**

1. В Grafana перейдите в **Dashboards → Import**
2. Нажмите **Upload JSON file**
3. Выберите файл `config/grafana-dashboard.json`
4. Выберите Prometheus data source
5. Нажмите **Import**

### 3. Готовые метрики в Dashboard

Dashboard включает следующие панели:

1. **CPU Usage (%)** - загрузка процессора
2. **Memory Usage (MB)** - использование памяти
3. **Requests per Second** - количество запросов в секунду
4. **Request Duration (ms)** - среднее время ответа
5. **Sidekiq Queue Size** - размер очереди фоновых задач
6. **Database Query Time (ms)** - время выполнения SQL запросов

## Настройка алертов (опционально)

### Пример алерта для высокой загрузки CPU

1. В Grafana перейдите в **Alerting → Alert rules**
2. Создайте новый alert rule:
   - **Name:** High CPU Usage
   - **Query:** `rate(process_cpu_seconds_total{job="rails"}[5m]) * 100 > 80`
   - **Condition:** WHEN last() OF query(A) IS ABOVE 80
   - **For:** 5m
3. Настройте notification channel (email, Slack, etc.)

### Пример алерта для большой очереди Sidekiq

```promql
sidekiq_queue_size > 100
```

## Мониторинг ресурсов контейнера

Для ограничения ресурсов контейнера можно использовать Docker options.
Проверить фактическое использование:
```bash
docker stats stackoverflow_clone-web-1
```

**Примечание:** В Kamal 2.7.0 resource limits и healthcheck настраиваются через Docker напрямую или через Traefik proxy, если используется.

## Метрики приложения

### Доступные метрики

**Process metrics:**
- `process_cpu_seconds_total` - CPU time
- `process_resident_memory_bytes` - Memory usage
- `process_virtual_memory_bytes` - Virtual memory
- `process_open_fds` - Open file descriptors

**HTTP metrics:**
- `http_requests_total` - Total requests
- `http_request_duration_seconds` - Request duration histogram

**ActiveRecord metrics:**
- `active_record_query_duration_seconds` - Query duration
- `active_record_instantiation_duration_seconds` - Model instantiation time

**Sidekiq metrics:**
- `sidekiq_queue_size` - Queue size by queue name
- `sidekiq_jobs_total` - Total jobs processed
- `sidekiq_job_duration_seconds` - Job duration

### Добавление кастомных метрик

Создайте файл `app/services/metrics_service.rb`:

```ruby
class MetricsService
  def self.track_custom_metric(name, value, labels = {})
    return if Rails.env.test?
    
    PrometheusExporter::Client.default.send_json(
      type: "custom",
      name: name,
      value: value,
      labels: labels
    )
  end
end
```

Использование:
```ruby
# В контроллере или сервисе
MetricsService.track_custom_metric(
  "user_signups_total",
  1,
  { source: "google_oauth" }
)
```

## Troubleshooting

### Prometheus не видит метрики

1. Проверьте, что prometheus_exporter запущен:
   ```bash
   docker exec stackoverflow_clone-web-1 ps aux | grep prometheus_exporter
   ```

2. Проверьте доступность метрик:
   ```bash
   curl http://90.156.228.95:9394/metrics
   ```

3. Проверьте конфигурацию Prometheus:
   ```bash
   docker exec stackoverflow_clone-prometheus cat /etc/prometheus/prometheus.yml
   ```

### Grafana не подключается к Prometheus

1. Проверьте, что оба контейнера используют `network: host`:
   ```bash
   docker inspect stackoverflow_clone-prometheus | grep NetworkMode
   docker inspect stackoverflow_clone-grafana | grep NetworkMode
   ```

2. Проверьте доступность Prometheus из Grafana:
   ```bash
   docker exec stackoverflow_clone-grafana curl http://localhost:9090/-/healthy
   ```

### Метрики не обновляются

1. Перезапустите prometheus_exporter:
   ```bash
   kamal app restart
   ```

2. Проверьте логи:
   ```bash
   kamal app logs | grep prometheus
   ```

## Безопасность

### Рекомендации для production

1. **Ограничьте доступ к Prometheus и Grafana через firewall:**
   ```bash
   # Разрешить доступ только с определенных IP
   ufw allow from YOUR_IP to any port 9090
   ufw allow from YOUR_IP to any port 3001
   ```

2. **Измените пароль Grafana:**
   - Войдите в Grafana
   - Перейдите в **Profile → Change Password**

3. **Настройте HTTPS через reverse proxy (nginx):**
   ```nginx
   server {
     listen 443 ssl;
     server_name monitoring.yourdomain.com;
     
     location / {
       proxy_pass http://localhost:3001;
     }
   }
   ```

4. **Включите аутентификацию для Prometheus:**
   Добавьте basic auth через nginx или используйте Grafana как прокси.

## Обслуживание

### Очистка старых метрик

Prometheus хранит метрики 30 дней (настроено через `--storage.tsdb.retention.time=30d`).

Для изменения срока хранения отредактируйте `config/deploy.yml`:
```yaml
prometheus:
  cmd: --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --storage.tsdb.retention.time=60d
```

### Бэкап конфигураций Grafana

```bash
# Экспортировать все dashboards
docker exec stackoverflow_clone-grafana grafana-cli admin export-dashboard > grafana-backup.json

# Или скопировать весь volume
docker run --rm -v stackoverflow_clone_grafana-data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-backup.tar.gz /data
```

## Полезные команды

```bash
# Перезапустить Prometheus
kamal accessory restart prometheus

# Перезапустить Grafana
kamal accessory restart grafana

# Посмотреть логи Prometheus
kamal accessory logs prometheus

# Посмотреть логи Grafana
kamal accessory logs grafana

# Удалить и пересоздать accessory
kamal accessory remove prometheus
kamal accessory boot prometheus
```

## Дополнительные ресурсы

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [prometheus_exporter gem](https://github.com/discourse/prometheus_exporter)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
