$(document).on('turbolinks:load', function() {
  $(document).on('click', '.add_comment, .edit_comment_button', function (e) {
    e.preventDefault();
    $(this).toggle();
    $(this).closest('.comment').find('.form_comment').toggle();
  });

  $(document).on('ajax:success', '.form_comment', function (e) {
    append_block_class = block_name(this.id, '.answer_comments .comments', '.question_comments .comments');
    comment_block($.parseJSON(e.detail[2].responseText)).appendTo(append_block_class);
    $(this).find('#question_comment_body').val('');
    $(this).toggle();
    $(this).closest('.question_comments').find('.add_comment').toggle();
  })
    .on('ajax:error', '.form_comment', function(e){
      append_block_class = block_name(this.id, '.answer-comment-errors', '.question-comment-errors');
      $(this).find(append_block_class).text(e.detail[0]);
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

  function block_name(check, first, second) {
    return  check === 'new_comment_answer' ? first : second;
  }
});
