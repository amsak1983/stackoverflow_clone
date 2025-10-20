# 🎯 Мониторинг и Бэкапы - Краткий обзор

## Что добавлено

### 📊 Мониторинг
- **Prometheus** (порт 9090) - сбор метрик
- **Grafana** (порт 3001) - визуализация с готовым dashboard
- **Healthcheck** - автоматическая проверка каждые 30 секунд
- **Resource limits** - CPU: 2 cores, RAM: 1024 MB

### 💾 Бэкапы
- Автоматический бэкап SQLite с WAL checkpoint
- Ежедневно в 2:00 ночи через cron
- Хранение последних 7 дней
- Сжатие gzip + проверка целостности

## 🚀 Быстрый старт

```bash
# 1. Установить зависимости
bundle install

# 2. Деплой
kamal deploy
kamal accessory boot prometheus
kamal accessory boot grafana

# 3. Настроить Grafana
# Открыть http://90.156.228.95:3001
# Войти: admin/admin (сменить пароль!)
# Добавить Prometheus: http://localhost:9090
# Импортировать dashboard: config/grafana-dashboard.json

# 4. Настроить cron (автоматически через post-deploy hook)
# Или вручную на сервере:
ssh root@90.156.228.95
crontab -e
# Добавить: 0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1
```

## 📊 Dashboard метрики

1. CPU Usage (%)
2. Memory Usage (MB)
3. Requests per Second
4. Request Duration (ms)
5. Sidekiq Queue Size
6. Database Query Time (ms)

## 🔍 Проверка

```bash
# Healthcheck
curl http://90.156.228.95:3000/up

# Метрики
curl http://90.156.228.95:9394/metrics

# Тестовый бэкап
docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh

# Список бэкапов
docker exec stackoverflow_clone-web-1 ls -lh /backups
```

## 📚 Полная документация

- **[PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)** - полная инструкция
- **[MONITORING_SETUP.md](MONITORING_SETUP.md)** - детали мониторинга
- **[BACKUP_SETUP.md](BACKUP_SETUP.md)** - детали бэкапов
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - чеклист
- **[CHANGELOG_MONITORING.md](CHANGELOG_MONITORING.md)** - список изменений

## 🔧 Основные команды

```bash
# Статус
kamal app details
kamal accessory details prometheus
kamal accessory details grafana

# Логи
kamal app logs -f
kamal accessory logs prometheus
kamal accessory logs grafana

# Перезапуск
kamal app restart
kamal accessory restart prometheus
kamal accessory restart grafana

# Бэкап вручную
docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh
```

## ✅ Готово!

Приложение развернуто с production-ready мониторингом и автоматическими бэкапами по best practices 2025 года.
