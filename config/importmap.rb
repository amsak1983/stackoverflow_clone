# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Flowbite с поддержкой turbo
pin "flowbite", to: "https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.turbo.min.js"
