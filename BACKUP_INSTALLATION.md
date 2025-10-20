# Установка системы бэкапа с Backup gem

## Что было добавлено

### 1. Гем backup
- Добавлен в `Gemfile`: `gem "backup", "~> 5.0"`

### 2. Конфигурационные файлы
- `config/backup.rb` - основная конфигурация Backup gem
- `config/sidekiq.yml` - обновлен с расписанием бэкапа

### 3. Код приложения
- `app/jobs/database_backup_job.rb` - Sidekiq job для автоматического бэкапа
- `lib/tasks/backup.rake` - Rake tasks для управления бэкапами

### 4. Документация
- `docs/backup/README.md` - обзор системы бэкапа
- `docs/backup/QUICK_START.md` - быстрый старт
- `docs/backup/BACKUP_GEM_SETUP.md` - полная документация

## Шаги для установки

### 1. Установите зависимости локально

```bash
bundle install
```

### 2. Проверьте конфигурацию

Убедитесь, что в `Dockerfile` установлен `sqlite3` (уже есть на строке 16):
```dockerfile
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
```

### 3. Задеплойте приложение

```bash
# Полный деплой с пересборкой образа
kamal deploy

# Или только перезапуск если образ уже собран
kamal app boot
```

### 4. Проверьте работу

```bash
# Запустите тестовый бэкап
kamal app exec 'bundle exec rake backup:run'

# Проверьте созданные бэкапы
kamal app exec 'bundle exec rake backup:list'
```

Вы должны увидеть что-то вроде:
```
Available backups in /backups:
  stackoverflow_clone_db.tar.gz (2.45 MB) - 2025-01-20 14:30:15
```

### 5. Проверьте автоматическое расписание

Откройте Sidekiq Web UI:
```
http://your-server-ip:3000/sidekiq/cron
```

Вы должны увидеть задачу `database_backup` с расписанием `0 2 * * *` (каждый день в 2:00).

## Что дальше?

1. **Прочитайте документацию**: `docs/backup/README.md`
2. **Настройте email уведомления** (опционально)
3. **Настройте хранение на S3** (рекомендуется для production)
4. **Протестируйте восстановление** из бэкапа

## Основные команды

```bash
# Ручной запуск бэкапа
kamal app exec 'bundle exec rake backup:run'

# Список бэкапов
kamal app exec 'bundle exec rake backup:list'

# Очистка старых бэкапов
kamal app exec 'bundle exec rake backup:clean'

# Просмотр логов
kamal app logs | grep DatabaseBackupJob
```

## Параметры по умолчанию

- **Расписание**: Каждый день в 2:00 ночи
- **Хранение**: Последние 7 бэкапов
- **Место**: Docker volume `stackoverflow_clone_backups` → `/backups`
- **Сжатие**: Gzip (уровень 6)
- **Разбивка**: Файлы > 250 MB разбиваются на части

## Troubleshooting

### Ошибка при bundle install

Если возникает ошибка при установке гема `backup`, попробуйте:
```bash
bundle update backup
```

### Бэкап не создается

1. Проверьте, что Sidekiq запущен:
```bash
docker ps | grep sidekiq
```

2. Проверьте логи:
```bash
kamal app logs | grep -i backup
```

3. Запустите вручную для диагностики:
```bash
kamal app exec 'bundle exec rake backup:run'
```

### Нет доступа к /backups

Проверьте права доступа:
```bash
kamal app exec 'ls -la /backups'
```

## Дополнительная информация

Полная документация находится в `docs/backup/BACKUP_GEM_SETUP.md`.
