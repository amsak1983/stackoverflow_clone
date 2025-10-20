# StackOverflow Clone

> Современный клон StackOverflow на Rails 8 с OAuth, поиском, API и production-ready инфраструктурой

## ✨ Возможности

- 🔐 **Аутентификация** - Devise + OAuth (Google, Telegram)
- 💬 **Q&A система** - вопросы, ответы, комментарии
- 👍 **Голосование** - upvote/downvote с репутацией
- 🏆 **Награды** - система достижений за лучшие ответы
- 🔍 **Поиск** - полнотекстовый поиск через Elasticsearch
- 📡 **Real-time** - WebSocket обновления через Action Cable
- 🔌 **API** - OAuth2 provider + JSON API
- 📊 **Мониторинг** - Prometheus + Grafana
- 💾 **Бэкапы** - автоматические резервные копии

## 🛠 Технологии

**Backend**
- Rails 8.0.2 + Ruby 3.2.6
- SQLite3 (Solid Cache/Queue/Cable)
- Sidekiq + Redis (фоновые задачи)
- Elasticsearch (поиск)

**Frontend**
- Hotwire (Turbo + Stimulus)
- TailwindCSS (Flowbite)
- ERB templates

**Infrastructure**
- Kamal (deployment)
- Prometheus + Grafana (мониторинг)
- Docker

## 🚀 Быстрый старт

```bash
# Клонировать репозиторий
git clone https://github.com/amsak1983/stackoverflow_clone
cd stackoverflow_clone

# Установить зависимости
bundle install
npm install

# Настроить базу данных
bin/rails db:setup

# Запустить dev сервер (Rails + Sidekiq + TailwindCSS)
bin/dev
```

Откройте http://localhost:3000

## 🧪 Тестирование

```bash
# RSpec тесты
bundle exec rspec

# Проверка безопасности
bundle exec brakeman

# Линтер
bundle exec rubocop
```

## 📦 Production

```bash
# Деплой через Kamal
kamal setup
kamal deploy

# Мониторинг
kamal accessory boot prometheus grafana
```

**Документация:** [docs/](docs/README.md)

## 📝 Лицензия

MIT
