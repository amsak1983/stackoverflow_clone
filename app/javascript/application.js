// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "flowbite"
import "@nathanvda/cocoon"

// Инициализация Cocoon для динамических вложенных форм
document.addEventListener("turbo:load", function() {
  document.addEventListener('click', function(e) {
    if (e.target && e.target.matches('.add_fields')) {
      e.preventDefault();
      const time = new Date().getTime();
      const regexp = new RegExp(e.target.dataset.id, 'g');
      const template = e.target.dataset.fieldsTemplate;
      const newFields = template.replace(regexp, time);
      e.target.insertAdjacentHTML('beforebegin', newFields);
    }
    
    if (e.target && e.target.matches('.remove_fields')) {
      e.preventDefault();
      const wrapper = e.target.closest('.nested-fields');
      if (wrapper.querySelector('input[type=hidden][name*=_destroy]')) {
        wrapper.querySelector('input[type=hidden][name*=_destroy]').value = '1';
      }
      wrapper.style.display = 'none';
    }
  });
});
