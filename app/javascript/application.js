// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import "flowbite"
import "jquery";
import "cocoon";

// Инициализируем Flowbite после каждой загрузки Turbo
document.addEventListener('turbo:load', () => {
  if (window.initFlowbite) { window.initFlowbite(); }
});
