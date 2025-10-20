# SQLite Backup Setup Guide

## Автоматическое резервное копирование через Cron

### Настройка на VPS сервере

1. **Подключитесь к серверу:**
   ```bash
   ssh root@90.156.228.95
   ```

2. **Откройте crontab для редактирования:**
   ```bash
   crontab -e
   ```

3. **Добавьте следующую строку для ежедневного бэкапа в 2:00 ночи:**
   ```cron
   0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1
   ```

4. **Альтернативный вариант - запуск через Kamal hook:**
   
   Создайте файл `.kamal/hooks/post-deploy` на сервере:
   ```bash
   #!/bin/bash
   # Setup cron job for backups after deployment
   
   CRON_JOB="0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh >> /var/log/sqlite-backup.log 2>&1"
   
   # Check if cron job already exists
   if ! crontab -l 2>/dev/null | grep -q "backup-sqlite.sh"; then
     (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
     echo "Backup cron job installed"
   else
     echo "Backup cron job already exists"
   fi
   ```
   
   Сделайте hook исполняемым:
   ```bash
   chmod +x .kamal/hooks/post-deploy
   ```

### Расписание бэкапов

По умолчанию настроено:
- **Частота:** Ежедневно в 2:00 ночи
- **Хранение:** Последние 7 дней
- **Место:** Docker volume `stackoverflow_clone_backups` → `/backups` в контейнере

### Изменение расписания

Формат cron: `минута час день месяц день_недели команда`

Примеры:
```cron
# Каждые 6 часов
0 */6 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh

# Каждый день в 3:30 утра
30 3 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh

# Каждое воскресенье в полночь
0 0 * * 0 /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh
```

### Проверка работы

1. **Проверить список cron задач:**
   ```bash
   crontab -l
   ```

2. **Запустить бэкап вручную для тестирования:**
   ```bash
   docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh
   ```

3. **Проверить созданные бэкапы:**
   ```bash
   docker exec stackoverflow_clone-web-1 ls -lh /backups
   ```

4. **Посмотреть логи бэкапов:**
   ```bash
   tail -f /var/log/sqlite-backup.log
   ```

### Восстановление из бэкапа

1. **Посмотреть доступные бэкапы:**
   ```bash
   docker exec stackoverflow_clone-web-1 ls -lh /backups
   ```

2. **Восстановить базу данных:**
   ```bash
   # Остановить приложение
   kamal app stop
   
   # Распаковать бэкап
   docker exec stackoverflow_clone-web-1 gunzip /backups/stackoverflow_clone-production-2025-01-20-020000.db.gz
   
   # Скопировать бэкап на место основной БД
   docker exec stackoverflow_clone-web-1 cp /backups/stackoverflow_clone-production-2025-01-20-020000.db /rails/storage/production.sqlite3
   
   # Запустить приложение
   kamal app start
   ```

### Копирование бэкапов на другой сервер (опционально)

Для дополнительной безопасности можно настроить копирование бэкапов на удаленный сервер:

```bash
# Добавить в crontab после основного бэкапа
0 3 * * * rsync -avz --delete /var/lib/docker/volumes/stackoverflow_clone_backups/_data/ backup-server:/backups/stackoverflow_clone/
```

### Мониторинг бэкапов

Скрипт бэкапа возвращает:
- **Exit code 0** - успешно
- **Exit code 1** - ошибка

Можно настроить алерты через cron:
```cron
MAILTO=your-email@example.com
0 2 * * * /usr/bin/docker exec stackoverflow_clone-web-1 /rails/bin/backup-sqlite.sh || echo "Backup failed!"
```

### Изменение срока хранения

Отредактируйте переменную `RETENTION_DAYS` в файле `bin/backup-sqlite.sh`:
```bash
RETENTION_DAYS=14  # Хранить 14 дней вместо 7
```

### Что бэкапится

Скрипт создает резервные копии всех production баз данных:
- `production.sqlite3` - основная БД
- `production_cache.sqlite3` - кэш (Solid Cache)
- `production_queue.sqlite3` - очередь задач (Solid Queue)
- `production_cable.sqlite3` - WebSocket connections (Solid Cable)

Каждая БД бэкапится отдельно с проверкой целостности и сжатием gzip.
