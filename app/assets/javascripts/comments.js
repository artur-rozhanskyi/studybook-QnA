$(document).on('turbolinks:load', function() {
  $(document).on('click', '.add_comment, .edit_comment_button', function (e) {
    e.preventDefault();
    $(this).toggle();
    $(this).closest('.comment').find('.form_comment').toggle();
  });

  PrivatePub.subscribe('/question/comments', function (data, chanel) {
      comment = data['comment'];
      action = data['action'];

      switch (action) {
        case 'create': comment_create(comment); break;
        case 'update': comment_update(comment); break;
        case 'destroy': comment_destroy(comment); break;
      }
  });

  function comment_parent(comment) {
    return $('*[data-' + comment.commentable_type.toLowerCase() + '-id=' + comment.commentable_id + ']');
  }

  function comment_create(comment){
    append_block_class = comment.commentable_type.toLowerCase();
    commentable_block = comment_parent(comment);
    comment_block(comment).appendTo(commentable_block.find('.comments'));
    $(commentable_block).find('.new_comment #' + append_block_class + '_comment_body').val('');
    $(commentable_block).find('#new_comment_' + append_block_class).toggle();
    $(commentable_block).find('.add_comment').toggle();
  }

  function comment_update(comment) {
    updated_comment = $('*[data-comment-id=' + comment.id + ']');
    prev_element = updated_comment.prev();
    updated_comment.remove();
    if(prev_element.length === 0){
      comment_parent(comment).find('.comments').prepend(comment_block(comment));
    }
    else {
      $(prev_element).after(comment_block(comment));
    }
  }

  function comment_destroy(comment) {
    $('*[data-comment-id=' + comment.id + ']').remove();
  }

  $(document).on('ajax:error', '.form_comment', function(e){
      append_block_class = block_name(this.id, '.answer-comment-errors', '.question-comment-errors');
      $(this).find(append_block_class).text(e.detail[0]);
  })
    .on('ajax:error', '.edit_comment', function(e){
      $(this).find('.question-comment-errors').text($.parseJSON(e.detail[0]));
    });
});

function comment_block(comment) {
  return $('<div>').addClass('comment')
    .attr('data-comment-id', comment.id)
    .append($('<p>' + comment.body + '</p>'))
    .append(comment_form_block(comment));
}

function comment_form_block(comment) {
  block = comment_form.content.cloneNode(true);
  if(gon.user_id !== 'undefined' && gon.user_id === comment.user_id){
    $(block).find('.edit_comment').attr({ 'id': 'edit_comment_' + comment.id,
      'action': '/comments/' + comment.id + '.js'});
    $(block).find('.edit_comment_button').attr('data-comment-id', comment.id);
    $(block).find('.del_cmt').attr({ 'action': '/comments/' + comment.id });
  }
  else{
    $(block).find('.edit_comment').remove();
    $(block).find('.edit_comment_button').remove();
    $(block).find('.del_cmt').remove();
  }


  $(block).find('#question_comment_body').val(comment.body);
  return block;
}

function block_name(check, first, second) {
  return  check === 'new_comment_answer' ? first : second;
}
