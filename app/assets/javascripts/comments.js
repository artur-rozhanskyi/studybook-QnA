$(document).on('turbolinks:load', function() {
  $(document).on('click', '.add_comment, .edit_comment_button', function (e) {
    e.preventDefault();
    $(this).toggle();
    $(this).closest('.comment').find('.form_comment').toggle();
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

  $(document).on('ajax:success', '.edit_comment', function (e) {
    comment = $.parseJSON(e.detail[2].responseText);
    prev_element = $(this).closest('.comment').prev();
    $(this).closest('.comment').remove();
    prev_element.after(comment_block(comment));
    if(prev_element.length === 0){
      $('.comments').prepend(comment_block(comment));
    }
    else {
      $(prev_elem).after(comment_block(comment));
    }
  })
    .on('ajax:error', '.edit_comment', function(e){
      $(this).find('.question-comment-errors').text(e.detail[0]);
    });

  function comment_block(comment) {
    return $('<div>').addClass('comment')
      .append($('<p>' + comment.body + '</p>'))
      .append(comment_form_block(comment));
  }
  
  function comment_form_block(comment) {
    block = comment_form.content.cloneNode(true);
    $(block).find('.edit_comment').attr({ 'id': 'edit_comment_' + comment.id,
                    'action': '/comments/' + comment.id + '.json'});
    $(block).find('.del_cmt').attr({ 'action': '/comments/' + comment.id });
    $(block).find('#question_comment_body').val(comment.body);
    return block;
  }
});
