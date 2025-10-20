# Мониторинг - Краткий обзор

## Что реализовано

- **Prometheus** (порт 9090) - сбор метрик
- **Grafana** (порт 3001) - визуализация
- **prometheus_exporter** - экспорт метрик из Rails
- **Healthcheck** - endpoint `/up`

## Dashboard метрики

1. CPU Usage (%)
2. Memory Usage (MB)
3. Requests per Second
4. Request Duration (ms)
5. Sidekiq Queue Size
6. Database Query Time (ms)

## Проверка

```bash
# Healthcheck
curl http://90.156.228.95:3000/up

# Метрики
curl http://90.156.228.95:9394/metrics
```

## Детали

См. [MONITORING_SETUP.md](MONITORING_SETUP.md) для полной инструкции.
