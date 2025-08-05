// Функциональность для поддержки динамических вложенных форм с cocoon
document.addEventListener('turbo:load', function() {
  document.addEventListener('click', function(e) {
    let link = e.target.closest('.add_fields');
    if (link) {
      e.preventDefault();
      let time = new Date().getTime();
      let linkId = link.dataset.id;
      let regexp = linkId ? new RegExp(linkId, 'g') : null;
      let newFields = link.dataset.fieldsHtml;
      
      if (regexp) {
        newFields = newFields.replace(regexp, time);
      }
      
      let target = document.getElementById(link.dataset.target) || link.parentNode;
      target.insertAdjacentHTML('beforeend', newFields);
    }
    
    let removeLink = e.target.closest('.remove_fields');
    if (removeLink) {
      e.preventDefault();
      let fieldset = removeLink.closest('fieldset');
      let hiddenField = fieldset.querySelector("input[type=hidden][name*='_destroy']");
      
      if (hiddenField) {
        hiddenField.value = '1';
      }
      
      fieldset.style.display = 'none';
    }
  });
});
