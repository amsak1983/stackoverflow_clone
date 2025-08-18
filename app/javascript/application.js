// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "flowbite"
import "jquery";
import "cocoon";

document.addEventListener('turbo:load', () => {
  if (window.initFlowbite) { window.initFlowbite(); }
});
