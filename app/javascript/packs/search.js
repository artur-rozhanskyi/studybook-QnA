(($) => {
  function formToggle(show, hide) {
    $(`.${show}`).show();
    $(`.${hide}`).hide();
  }

  $(document).on('turbolinks:load', () => {
    $(document).on('click', '.simple_search_button', (e) => {
      e.preventDefault();
      formToggle('simple_form', 'advanced_forms');
    });

    $(document).on('click', '.advanced_search_button', (e) => {
      e.preventDefault();
      formToggle('advanced_forms', 'simple_form');
    });
  });
})(jQuery);
