# 🚀 Production Deployment Checklist

## Перед деплоем

- [ ] Установлены зависимости: `bundle install`
- [ ] Проверен `.env` файл с секретами
- [ ] Проверен `config/deploy.yml`
- [ ] Собран Docker образ локально (опционально)

## Деплой

```bash
# 1. Деплой основного приложения
kamal deploy

# 2. Деплой Prometheus
kamal accessory boot prometheus

# 3. Деплой Grafana
kamal accessory boot grafana
```

## После деплоя

### Проверка работоспособности

- [ ] Приложение доступно: http://90.156.228.95:3000
- [ ] Healthcheck работает: `curl http://90.156.228.95:3000/up`
- [ ] Метрики доступны: `curl http://90.156.228.95:9394/metrics`
- [ ] Prometheus работает: http://90.156.228.95:9090
- [ ] Grafana работает: http://90.156.228.95:3001

### Настройка Grafana

- [ ] Войти в Grafana (admin/admin)
- [ ] Сменить пароль администратора
- [ ] Добавить Prometheus data source (http://localhost:9090)
- [ ] Импортировать dashboard из `config/grafana-dashboard.json`

### Настройка бэкапов

```bash
# На сервере
ssh root@90.156.228.95

# Добавить в crontab
crontab -e

# Вставить строку:
0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1
```

- [ ] Cron задача добавлена
- [ ] Тестовый бэкап выполнен: `docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh`
- [ ] Бэкапы создаются: `docker exec stackoverflow_clone-web-1 ls -lh /backups`

### Безопасность

- [ ] Пароль Grafana изменен
- [ ] Firewall настроен (опционально):
  ```bash
  ufw allow from ВАШ_IP to any port 9090
  ufw allow from ВАШ_IP to any port 3001
  ```
- [ ] Секреты не закоммичены в Git

### Мониторинг

- [ ] Dashboard в Grafana показывает метрики
- [ ] CPU usage отображается
- [ ] Memory usage отображается
- [ ] Requests per second работает
- [ ] Sidekiq queue size виден

## Команды для проверки

```bash
# Статус всех сервисов
kamal app details
kamal accessory details prometheus
kamal accessory details grafana

# Логи
kamal app logs -f
kamal accessory logs prometheus
kamal accessory logs grafana

# Статистика контейнеров
ssh root@90.156.228.95 "docker stats"

# Проверка бэкапов
docker exec stackoverflow_clone-web-1 ls -lh /backups
```

## Полезные ссылки

- [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md) - полная инструкция
- [MONITORING_SETUP.md](../monitoring/MONITORING_SETUP.md) - детали мониторинга
- [BACKUP_SETUP.md](../backup/BACKUP_SETUP.md) - детали бэкапов
- [Главная документация](../README.md) - вернуться к оглавлению

## Контакты для алертов (настроить)

- [ ] Email для алертов: _______________
- [ ] Slack webhook (опционально): _______________
- [ ] Telegram bot (опционально): _______________

---

✅ **Деплой завершен!** Приложение работает с мониторингом и автоматическими бэкапами.
