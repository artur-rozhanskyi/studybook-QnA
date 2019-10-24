$(document).on('turbolinks:load', function() {
  $(document).on('click', '.edit-answer-link', function(e) {
    e.preventDefault();
    $(this).hide();
    answer_id = $(this).data('answerId');
    $('form#edit-answer-' + answer_id).show();
  });
});
