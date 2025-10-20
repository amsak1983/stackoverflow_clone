# Changelog - Мониторинг и Бэкапы

## 📅 Дата: 2025-01-20

## 🎯 Цель
Добавление production-ready мониторинга и резервного копирования для Rails 8 приложения на VPS через Kamal.

---

## ✨ Добавленные функции

### 1. Мониторинг процессов через Prometheus + Grafana

#### Новые файлы:
- `config/initializers/prometheus.rb` - инициализация prometheus_exporter
- `config/prometheus.yml` - конфигурация Prometheus
- `config/grafana-dashboard.json` - готовый dashboard для Grafana
- `bin/start-prometheus-exporter` - скрипт запуска exporter

#### Изменения в существующих файлах:
- `Gemfile` - добавлен `prometheus_exporter` gem
- `config/application.rb` - добавлен PrometheusExporter::Middleware
- `config/routes.rb` - добавлен маршрут `/metrics`
- `bin/docker-entrypoint` - автозапуск prometheus_exporter
- `config/deploy.yml` - добавлены accessories для Prometheus и Grafana

#### Метрики:
- CPU usage (%)
- Memory usage (MB)
- Requests per second
- Request duration (ms)
- Sidekiq queue size
- Database query time (ms)
- ActiveRecord metrics
- Process metrics

#### Доступ:
- **Prometheus:** http://90.156.228.95:9090
- **Grafana:** http://90.156.228.95:3001 (admin/admin)
- **Metrics endpoint:** http://90.156.228.95:9394/metrics

---

### 2. Healthcheck для автоматического мониторинга

#### Изменения:
- `config/deploy.yml` - добавлена секция `healthcheck`

#### Параметры:
- **Endpoint:** `/up` (уже существовал в Rails 8)
- **Interval:** 30 секунд
- **Timeout:** 10 секунд
- **Retries:** 3 попытки

Kamal автоматически перезапускает контейнер при падении healthcheck.

---

### 3. Resource limits для Puma контейнера

#### Изменения:
- `config/deploy.yml` - добавлена секция `resources`

#### Лимиты:
- **CPU Limit:** 2 cores
- **CPU Reservation:** 0.5 cores
- **Memory Limit:** 1024 MB
- **Memory Reservation:** 512 MB

Предотвращает перегрузку сервера и обеспечивает стабильную работу.

---

### 4. Резервное копирование SQLite

#### Новые файлы:
- `bin/backup-sqlite.sh` - основной скрипт бэкапа
- `bin/docker-backup.sh` - wrapper для запуска из хоста

#### Изменения:
- `config/deploy.yml` - добавлен volume `stackoverflow_clone_backups`

#### Функции скрипта:
- ✅ WAL checkpoint для целостности данных
- ✅ Бэкап всех 4 production баз данных
- ✅ Проверка целостности каждого бэкапа (PRAGMA integrity_check)
- ✅ Сжатие gzip для экономии места
- ✅ Автоматическая очистка старых бэкапов (7 дней)
- ✅ Цветной вывод логов
- ✅ Обработка ошибок

#### Что бэкапится:
1. `production.sqlite3` - основная БД
2. `production_cache.sqlite3` - Solid Cache
3. `production_queue.sqlite3` - Solid Queue
4. `production_cable.sqlite3` - Solid Cable

#### Расписание:
Настраивается через cron (ежедневно в 2:00 ночи):
```cron
0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1
```

---

## 📚 Документация

Созданы подробные руководства:

1. **PRODUCTION_DEPLOYMENT.md** - главная инструкция по деплою
2. **MONITORING_SETUP.md** - детальная настройка мониторинга
3. **BACKUP_SETUP.md** - детальная настройка бэкапов
4. **DEPLOYMENT_CHECKLIST.md** - чеклист для быстрого деплоя

---

## 🔧 Команды для деплоя

```bash
# 1. Установить зависимости
bundle install

# 2. Деплой приложения
kamal deploy

# 3. Деплой Prometheus
kamal accessory boot prometheus

# 4. Деплой Grafana
kamal accessory boot grafana

# 5. Настроить cron на сервере
ssh root@90.156.228.95
crontab -e
# Добавить: 0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1
```

---

## 🎨 Архитектура

```
┌─────────────────────────────────────────────────────────┐
│                    VPS Server                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Rails App (Puma)                                │  │
│  │  - Port: 3000                                    │  │
│  │  - CPU: 2 cores (limit), 0.5 cores (reserved)   │  │
│  │  - RAM: 1024 MB (limit), 512 MB (reserved)      │  │
│  │  - Healthcheck: /up (every 30s)                 │  │
│  │  - Metrics: :9394/metrics                       │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                              │
│                          ↓                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Prometheus                                      │  │
│  │  - Port: 9090                                    │  │
│  │  - Scrapes metrics every 15s                    │  │
│  │  - Retention: 30 days                           │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                              │
│                          ↓                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Grafana                                         │  │
│  │  - Port: 3001                                    │  │
│  │  - Dashboard: CPU, RAM, RPS, Sidekiq, DB       │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Cron Job (daily 2:00 AM)                       │  │
│  │  - Runs backup-sqlite.sh                        │  │
│  │  - WAL checkpoint                               │  │
│  │  - Backup 4 databases                           │  │
│  │  - Compress with gzip                           │  │
│  │  - Keep last 7 days                             │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Best Practices 2025

Реализованы следующие best practices:

### Мониторинг:
- ✅ Prometheus как стандарт для метрик
- ✅ Grafana для визуализации
- ✅ Healthcheck для автоматического восстановления
- ✅ Resource limits для предотвращения перегрузки
- ✅ Метрики приложения (CPU, RAM, RPS, Sidekiq)
- ✅ Метрики базы данных (query time, connections)

### Бэкапы:
- ✅ WAL checkpoint для целостности SQLite
- ✅ Проверка целостности каждого бэкапа
- ✅ Сжатие для экономии места
- ✅ Автоматическая ротация (retention policy)
- ✅ Логирование всех операций
- ✅ Обработка ошибок

### Безопасность:
- ✅ Бэкапы в отдельном Docker volume
- ✅ Resource limits для изоляции
- ✅ Healthcheck для быстрого обнаружения проблем
- ✅ Логирование для аудита

### Простота:
- ✅ Без Kubernetes (простой VPS)
- ✅ Без AWS (локальные бэкапы)
- ✅ Без сложных инструментов (только Docker + Kamal)
- ✅ Подробная документация на русском
- ✅ Готовые скрипты и конфигурации

---

## 🔄 Обратная совместимость

Все изменения обратно совместимы:
- Существующие маршруты не изменены
- Существующая функциональность не затронута
- Новые зависимости не конфликтуют с существующими
- Можно откатиться, удалив новые accessories

---

## 📊 Производительность

Влияние на производительность:
- **prometheus_exporter:** ~5-10 MB RAM, минимальная нагрузка на CPU
- **Prometheus:** ~100-200 MB RAM (отдельный контейнер)
- **Grafana:** ~100-150 MB RAM (отдельный контейнер)
- **Бэкапы:** выполняются ночью, не влияют на работу приложения

---

## 🐛 Известные ограничения

1. **Prometheus и Grafana доступны без аутентификации** - рекомендуется настроить firewall
2. **Бэкапы хранятся локально** - для критичных данных рекомендуется копировать на удаленный сервер
3. **Grafana пароль по умолчанию** - нужно сменить при первом входе

---

## 🚀 Следующие шаги (опционально)

1. Настроить алерты в Grafana
2. Копировать бэкапы на удаленный сервер
3. Настроить HTTPS для Grafana
4. Добавить кастомные метрики для бизнес-логики
5. Интегрировать с внешним логированием (ELK, Loki)

---

## 📝 Примечания

- Все скрипты протестированы с Rails 8.0.2
- Совместимо с Kamal 2.x
- Работает на Ubuntu/Debian VPS
- SQLite в WAL mode (по умолчанию в Rails 8)

---

**Автор:** AI Assistant  
**Дата:** 2025-01-20  
**Версия:** 1.0
