# 📚 Production Monitoring & Backup

Production-ready мониторинг и резервное копирование для Rails 8 приложения.

## 🚀 Быстрый старт

- **[PRODUCTION_DEPLOYMENT.md](deployment/PRODUCTION_DEPLOYMENT.md)** - полное руководство
- **[DEPLOYMENT_CHECKLIST.md](deployment/DEPLOYMENT_CHECKLIST.md)** - чеклист

## 📖 Документация

**Deployment**
- [PRODUCTION_DEPLOYMENT.md](deployment/PRODUCTION_DEPLOYMENT.md) - полное руководство по деплою
- [DEPLOYMENT_CHECKLIST.md](deployment/DEPLOYMENT_CHECKLIST.md) - чеклист

**Monitoring**
- [MONITORING_SETUP.md](monitoring/MONITORING_SETUP.md) - настройка Prometheus + Grafana
- [README.md](monitoring/README.md) - краткий обзор

**Backup**
- [BACKUP_SETUP.md](backup/BACKUP_SETUP.md) - автоматические бэкапы SQLite

**История**
- [CHANGELOG_MONITORING.md](CHANGELOG_MONITORING.md) - changelog

## 🎯 Реализовано

✅ Prometheus (порт 9090) + Grafana (порт 3001)  
✅ Автоматические бэкапы SQLite (ежедневно в 2:00)  
✅ Healthcheck endpoint `/up`  
✅ Cron автоматизация через post-deploy hooks  

## 📝 Команды

```bash
# Деплой
kamal deploy
kamal accessory boot prometheus grafana

# Проверка
curl http://90.156.228.95:3000/up
kamal app details

# Бэкап
docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh
```

---

**Rails 8.0.2 | Kamal 2.7.0**
