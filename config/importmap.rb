# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Flowbite с поддержкой turbo
pin "jquery", to: "vendor/jquery-3.7.1.min.js"
pin "flowbite", to: "vendor/flowbite.turbo.min.js"

# Cocoon for dynamic nested forms
pin "cocoon", to: "vendor/cocoon.min.js"
