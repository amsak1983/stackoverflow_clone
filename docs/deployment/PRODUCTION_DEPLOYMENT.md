# Production Deployment Guide - Мониторинг и Бэкапы

## 🎯 Что было добавлено

### ✅ Мониторинг процессов
- **Prometheus** - сбор метрик (порт 9090)
- **Grafana** - визуализация (порт 3001)
- **prometheus_exporter** - экспорт метрик из Rails
- **Healthcheck** - автоматическая проверка состояния приложения
- **Resource limits** - ограничения CPU (2 cores) и RAM (1024 MB)

### ✅ Резервное копирование SQLite
- Автоматический бэкап всех production баз данных
- WAL checkpoint для целостности данных
- Сжатие gzip для экономии места
- Хранение последних 7 дней
- Проверка целостности каждого бэкапа

## 🚀 Быстрый старт

### Шаг 1: Установка зависимостей

```bash
# На локальной машине
bundle install
```

### Шаг 2: Деплой приложения

```bash
# Деплой основного приложения с новыми настройками
kamal deploy

# Деплой Prometheus
kamal accessory boot prometheus

# Деплой Grafana
kamal accessory boot grafana
```

### Шаг 3: Настройка автоматических бэкапов

```bash
# Подключитесь к серверу
ssh root@90.156.228.95

# Откройте crontab
crontab -e

# Добавьте строку для ежедневного бэкапа в 2:00 ночи
0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1
```

### Шаг 4: Настройка Grafana

1. Откройте http://90.156.228.95:3001
2. Войдите (admin/admin) и смените пароль
3. Добавьте Prometheus data source:
   - Configuration → Data Sources → Add data source
   - Выберите Prometheus
   - URL: `http://localhost:9090`
   - Save & Test
4. Импортируйте dashboard:
   ```bash
   curl -X POST http://admin:НОВЫЙ_ПАРОЛЬ@90.156.228.95:3001/api/dashboards/db \
     -H "Content-Type: application/json" \
     -d @config/grafana-dashboard.json
   ```

## 📊 Доступ к сервисам

| Сервис | URL | Аутентификация |
|--------|-----|----------------|
| **Приложение** | http://90.156.228.95:3000 | Devise |
| **Prometheus** | http://90.156.228.95:9090 | Нет |
| **Grafana** | http://90.156.228.95:3001 | admin/admin |
| **Sidekiq** | http://90.156.228.95:3000/sidekiq | Basic Auth |
| **Метрики** | http://90.156.228.95:9394/metrics | Нет |

## 🔍 Проверка работы

### Проверить healthcheck
```bash
curl http://90.156.228.95:3000/up
# Должен вернуть: 200 OK
```

### Проверить метрики
```bash
curl http://90.156.228.95:9394/metrics
# Должен вернуть метрики в формате Prometheus
```

### Проверить статус контейнеров
```bash
kamal app details
kamal accessory details prometheus
kamal accessory details grafana
```

### Запустить тестовый бэкап
```bash
docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh
```

### Проверить созданные бэкапы
```bash
docker exec stackoverflow_clone-web-1 ls -lh /backups
```

## 📈 Метрики в Grafana Dashboard

Dashboard включает 6 панелей:

1. **CPU Usage (%)** - загрузка процессора Rails процесса
2. **Memory Usage (MB)** - использование оперативной памяти
3. **Requests per Second** - количество HTTP запросов в секунду
4. **Request Duration (ms)** - среднее время обработки запросов
5. **Sidekiq Queue Size** - размер очереди фоновых задач
6. **Database Query Time (ms)** - среднее время выполнения SQL запросов

## 💾 Резервное копирование

### Что бэкапится

- `production.sqlite3` - основная БД
- `production_cache.sqlite3` - кэш (Solid Cache)
- `production_queue.sqlite3` - очередь задач (Solid Queue)
- `production_cable.sqlite3` - WebSocket connections (Solid Cable)

### Параметры бэкапа

- **Расписание:** Ежедневно в 2:00 ночи
- **Хранение:** 7 дней
- **Формат:** `.db.gz` (сжатый gzip)
- **Место:** Docker volume `stackoverflow_clone_backups`

### Восстановление из бэкапа

```bash
# 1. Остановить приложение
kamal app stop

# 2. Посмотреть доступные бэкапы
docker exec stackoverflow_clone-web-1 ls -lh /backups

# 3. Распаковать нужный бэкап
docker exec stackoverflow_clone-web-1 gunzip /backups/stackoverflow_clone-production-2025-01-20-020000.db.gz

# 4. Скопировать на место основной БД
docker exec stackoverflow_clone-web-1 cp /backups/stackoverflow_clone-production-2025-01-20-020000.db /rails/storage/production.sqlite3

# 5. Запустить приложение
kamal app start
```

## 🔧 Управление

### Перезапуск сервисов

```bash
# Перезапустить приложение
kamal app restart

# Перезапустить Prometheus
kamal accessory restart prometheus

# Перезапустить Grafana
kamal accessory restart grafana
```

### Просмотр логов

```bash
# Логи приложения
kamal app logs -f

# Логи Prometheus
kamal accessory logs prometheus

# Логи Grafana
kamal accessory logs grafana

# Логи бэкапов (на сервере)
ssh root@90.156.228.95 "tail -f /var/log/sqlite-backup.log"
```

### Мониторинг ресурсов

```bash
# Статистика контейнеров в реальном времени
ssh root@90.156.228.95 "docker stats"

# Проверить лимиты контейнера
docker inspect stackoverflow_clone-web-1 | grep -A 10 "Resources"
```

## 🔐 Безопасность (рекомендации)

### 1. Ограничить доступ к мониторингу

```bash
# На сервере настроить firewall
ufw allow from ВАШ_IP to any port 9090  # Prometheus
ufw allow from ВАШ_IP to any port 3001  # Grafana
```

### 2. Изменить пароль Grafana

После первого входа обязательно смените пароль:
- Profile → Change Password

### 3. Настроить HTTPS (опционально)

Используйте nginx как reverse proxy с Let's Encrypt SSL.

### 4. Копирование бэкапов на удаленный сервер

```bash
# Добавить в crontab для копирования на backup-сервер
0 3 * * * rsync -avz /var/lib/docker/volumes/stackoverflow_clone_backups/_data/ backup-server:/backups/
```

## 📚 Дополнительная документация

- **[MONITORING_SETUP.md](../monitoring/MONITORING_SETUP.md)** - подробная настройка мониторинга
- **[BACKUP_SETUP.md](../backup/BACKUP_SETUP.md)** - подробная настройка бэкапов
- **[Главная документация](../README.md)** - вернуться к оглавлению

## 🐛 Troubleshooting

### Prometheus не собирает метрики

```bash
# Проверить, что prometheus_exporter запущен
docker exec stackoverflow_clone-web-1 ps aux | grep prometheus_exporter

# Перезапустить приложение
kamal app restart
```

### Grafana не подключается к Prometheus

```bash
# Проверить доступность Prometheus
docker exec stackoverflow_clone-grafana curl http://localhost:9090/-/healthy

# Проверить network mode
docker inspect stackoverflow_clone-prometheus | grep NetworkMode
```

### Бэкап не создается

```bash
# Проверить логи
ssh root@90.156.228.95 "tail -100 /var/log/sqlite-backup.log"

# Запустить вручную для диагностики
docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh
```

### Нехватка места для бэкапов

```bash
# Проверить размер volume
docker system df -v | grep stackoverflow_clone_backups

# Уменьшить срок хранения (отредактировать bin/backup-sqlite.sh)
RETENTION_DAYS=3  # вместо 7

# Или очистить старые бэкапы вручную
docker exec stackoverflow_clone-web-1 find /backups -name "*.db.gz" -mtime +3 -delete
```

## 📞 Поддержка

При возникновении проблем:

1. Проверьте логи: `kamal app logs`
2. Проверьте статус: `kamal app details`
3. Проверьте healthcheck: `curl http://90.156.228.95:3000/up`
4. Проверьте метрики: `curl http://90.156.228.95:9394/metrics`

## ✨ Что дальше?

### Рекомендуемые улучшения:

1. **Алерты** - настроить уведомления в Grafana при высокой нагрузке
2. **Удаленные бэкапы** - копировать на отдельный сервер или S3-совместимое хранилище
3. **HTTPS** - настроить SSL через nginx + Let's Encrypt
4. **Логирование** - добавить централизованное логирование (ELK, Loki)
5. **APM** - добавить Application Performance Monitoring (New Relic, Scout APM)

---

**Версия:** 1.0  
**Дата:** 2025-01-20  
**Rails:** 8.0.2  
**Kamal:** 2.x
