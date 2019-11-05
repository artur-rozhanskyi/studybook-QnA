$(document).on('turbolinks:load', function() {
  $(document).on('click', '.add_comment', function (e) {
    e.preventDefault();
    $(this).toggle();
    $(this).closest('.question_comments').find('#new_comment_question').toggle();
  });

  $(document).on('ajax:success', '#new_comment_question', function (e) {
    comment_block($.parseJSON(e.detail[2].responseText)).appendTo('.question_comments .comments');
    $(this).find('#question_comment_body').val('');
    $(this).toggle();
    $(this).closest('.question_comments').find('.add_comment').toggle();
  })
    .on('ajax:error', '#new_comment_question', function(e){
      $(this).find('.question-comment-errors').text(e.detail[0]);
    });

  function comment_block(comment) {
    return $('<div>').addClass('comment').append($('<p>').text(comment.body));
  }
});
