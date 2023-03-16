import commentBlock from './comments';
import errorsStr from './helper';


(($) => {
  function fileBlock(attachment) {
    const div = $('<div>');
    div.append($('<p>').append($('<a>').attr('href', attachment.url).text(attachment.filename)));
    const inputHiddenLabel = $('<input>').attr({
      name: `answer[attachments_attributes][${attachment.id}][_destroy]`,
      type: 'hidden',
      value: attachment.id,
    });
    const inputHidden = $('<input>').attr({
      name: `answer[attachments_attributes][${attachment.id}][id]`,
      type: 'hidden',
      value: attachment.id,
      id: `answer[attachments_attributes][${attachment.id}][id]`,
    });
    const inputCheckboxLabel = $('<input>').attr({
      name: `answer[attachments_attributes][${attachment.id}][_destroy]`,
      type: 'checkbox',
      id: `answer_attachments_attributes_${attachment.id}__destroy`,
      value: 1,
    });
    $('<label>').attr('for', `answer_attachments_attributes_${attachment.id}__destroy`)
      .text('Remove file')
      .prepend(inputCheckboxLabel)
      .prepend(inputHiddenLabel)
      .appendTo(div);
    return div.append(inputHidden);
  }

  function inputBlock(index) {
    const div = $('<div>').attr('class', 'file');
    const inputFile = $('<input>').attr({
      name: `answer[attachments_attributes][${index}][file]`,
      type: 'file',
      value: '',
      id: `answer_attachments_attributes_${index}_file`,
    });
    const label = $('<label>').attr('for', `answer_attachments_attributes_${index}_file`).text('File');
    return div.append(label).append(inputFile);
  }

  function attachmentInputs(answer, block, filesBlock) {
    if (typeof answer.attachments !== 'undefined') {
      answer.attachments.forEach((attachment) => {
        filesBlock.append(fileBlock(attachment));
      });
      $(block).find('form .files').append(inputBlock(answer.attachments.length));
    }
  }

  function answerComments(answer, block) {
    answer.comments.forEach((comment) => {
      $(block).find('.comments').append(commentBlock(comment));
    });
    if (typeof (gon.user_id) !== 'undefined') {
      const newComment = document.getElementById('new_comment_form').content.cloneNode(true);
      $(newComment).find('#new_comment_answer')
        .attr('action', `/answers/${answer.id}/comments.json`);
      $(block).find('.answer').append($(newComment));
    }
  }

  function attachmentLinks(answer, block) {
    if (typeof answer.attachments !== 'undefined') {
      answer.attachments.forEach((attachment) => {
        const linkToFile = $('<a>').attr('href', attachment.url).text(attachment.filename);
        $(block).find('p').first().prepend(linkToFile);
      });
    }
  }

  function answerBlock(answer, block) {
    const link = $(block).find('.edit-answer-link');
    const userOwnerId = $('.question').data('userOwnerId');
    if (gon.user_id === answer.user_id) {
      link.next().attr('href', `/questions/${answer.question_id}/answers/${answer.id}`);

      $(block).find('form').attr({
        id: `edit_answer_${answer.id}`,
        action: `/answers/${answer.id}.json`,
      });
      $(block).find('textarea').attr({ id: `answer_textarea_${answer.id}` }).text(answer.body);
      attachmentInputs(answer, block, $(block).find('.files'));
    } else {
      link.next().remove();
      link.remove();
      $(block).find('form').remove();
    }

    if (userOwnerId === gon.user_id) {
      $(block).find('.best_answer_button').parent().attr('action', `/answers/${answer.id}/best`);
    }

    $(block).find('.answer').attr('data-answer-id', answer.id);
    answerComments(answer, block);
    attachmentLinks(answer, block);

    $(block).find('#ans_body').prepend(answer.body);

    return block;
  }

  function updateAnswer(answer) {
    const prevElem = $(`*[data-answer-id=${answer.id}]`).prev();
    $(`*[data-answer-id=${answer.id}]`).remove();
    if (prevElem.length === 0) {
      $('.answers').prepend(answerBlock(answer, document.getElementById('tmpl').content.cloneNode(true)));
    } else {
      $(prevElem).after(answerBlock(answer, document.getElementById('tmpl').content.cloneNode(true)));
    }
  }

  function destroyAnswer(answer) {
    $(`*[data-answer-id=${answer.id}]`).remove();
  }

  function newAnswer(answer) {
    $('.answers').append(answerBlock(answer, document.getElementById('tmpl').content.cloneNode(true)));
    $('#answer_body').val('');
    $('#new_answer input').val('');
    $('#new_answer .file:not(:first-child)').remove();
  }

  function bestAnswer(answer) {
    $('.best_answer_mark, .best_answer_button').remove();
    $(`*[data-answer-id=${answer.id}]`)
      .find('.nav_likes')
      .prepend($('<div>')
        .addClass('best_answer_mark')
        .append(document.getElementById('best_answer_mark_template').content.cloneNode(true)));
  }

  $(document).on('turbolinks:load', () => {
    const questionId = $('.question').data('questionId');
    $(document).on('click', '.edit-answer-link', (e) => {
      e.preventDefault();
      $(e.target).hide();
      const answerId = $(e.target).closest('.answer').data('answerId');
      $(`form#edit_answer_${answerId}`).show();
    });

    App.cable.subscriptions.create(
      {
        channel: 'AnswersChannel',
        question_id: questionId,
      },
      {
        received(data) {
          const { answer, action } = data;

          switch (action) {
            case 'create':
              newAnswer(answer);
              break;
            case 'update':
              updateAnswer(answer);
              break;
            case 'destroy':
              destroyAnswer(answer);
              break;
            case 'best':
              bestAnswer(answer);
              break;
            default: break;
          }
        },
      },
    );

    $(document).on('ajax:error', '#new_answer', (e) => {
      errorsStr(e.detail[0].errors);
      $(e.target).find('.answer-new-errors').text(errorsStr(e.detail[0].errors));
    }).on('ajax:error', 'form.edit_answer', (e) => {
      $(e.target).find('.answer-errors').text(errorsStr(e.detail[0].errors));
    });
  });
})(jQuery);
