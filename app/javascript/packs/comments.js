function commentFormBlock(comment) {
  const block = document.getElementById('comment_form').content.cloneNode(true);
  if (gon.user_id !== 'undefined' && gon.user_id === comment.user_id) {
    $(block).find('.edit_comment').attr({
      id: `edit_comment_${comment.id}`,
      action: `/comments/${comment.id}.js`,
    });
    $(block).find('.edit_comment_button').attr('data-comment-id', comment.id);
    $(block).find('.del_cmt').attr({ action: `/comments/${comment.id}` });
  } else {
    $(block).find('.edit_comment').remove();
    $(block).find('.edit_comment_button').remove();
    $(block).find('.del_cmt').remove();
  }

  $(block).find('#question_comment_body').val(comment.body);
  return block;
}

function blockName(check, first, second) {
  return check === 'new_comment_answer' ? first : second;
}

function commentParent(comment) {
  return $(`*[data-${comment.commentable_type.toLowerCase()}-id=${comment.commentable_id}]`);
}


export default function commentBlock(comment) {
  return $('<div>').addClass('comment')
    .attr('data-comment-id', comment.id)
    .append($(`<p>${comment.body}</p>`))
    .append(commentFormBlock(comment));
}

function commentCreate(comment) {
  const appendBlockClass = comment.commentable_type.toLowerCase();
  const commentableBlock = commentParent(comment);
  commentBlock(comment).appendTo(commentableBlock.find('.comments'));
  $(commentableBlock).find(`.new_comment #${appendBlockClass}_comment_body`).val('');
  $(commentableBlock).find(`#new_comment_${appendBlockClass}`).toggle();
  $(commentableBlock).find('.add_comment').toggle();
}

function commentUpdate(comment) {
  const updatedComment = $(`*[data-comment-id=${comment.id}]`);
  const prevElement = updatedComment.prev();
  updatedComment.remove();
  if (prevElement.length === 0) {
    commentParent(comment).find('.comments').prepend(commentBlock(comment));
  } else {
    $(prevElement).after(commentBlock(comment));
  }
}

function commentDestroy(comment) {
  $(`*[data-comment-id=${comment.id}]`).remove();
}

(($) => {
  $(document).on('turbolinks:load', () => {
    $(document).on('click', '.add_comment, .edit_comment_button', (e) => {
      e.preventDefault();
      $(e.target).toggle();
      $(e.target).closest('.comment').find('.form_comment').toggle();
    });

    App.cable.subscriptions.create('CommentsChannel', {
      received(data) {
        const { comment, action } = data;

        switch (action) {
          case 'create':
            commentCreate(comment);
            break;
          case 'update':
            commentUpdate(comment);
            break;
          case 'destroy':
            commentDestroy(comment);
            break;
          default: break;
        }
      },
    });

    $(document).on('ajax:error', '.form_comment', (e) => {
      const appendBlockClass = blockName(e.target.id, '.answer-comment-errors', '.question-comment-errors');
      $(e.target).find(appendBlockClass).text(e.detail[0]);
    })
      .on('ajax:error', '.edit_comment', (e) => {
        $(e.target).find('.question-comment-errors').text($.parseJSON(e.detail[0]));
      });
  });
})(jQuery);
