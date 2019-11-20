// eslint-disable-next-line import/named
import commentBlock from './comments';

(($) => {
  function fileBlock(attachment, index) {
    const div = $('<div>');
    div.append($('<p>').append($('<a>').attr('href', attachment.url).text(attachment.filename)));
    const inputHiddenLabel = $('<input>').attr({
      name: `answer[attachments_attributes][${index}][_destroy]`,
      type: 'hidden',
      value: 0,
    });
    const inputHidden = $('<input>').attr({
      name: `answer[attachments_attributes][${index}][id]`,
      type: 'hidden',
      value: attachment.id,
      id: `answer[attachments_attributes][${index}][id]`,
    });
    const inputCheckboxLabel = $('<input>').attr({
      name: `answer[attachments_attributes][${index}][_destroy]`,
      type: 'checkbox',
      id: `answer_attachments_attributes_${index}__destroy`,
    });
    $('<label>').attr('for', `answer_attachments_attributes_${index}__destroy`)
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
      answer.attachments.forEach((attachment, index) => {
        filesBlock.append(fileBlock(attachment, index));
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
        .attr('action', `/questions/${answer.question_id}/answers/${answer.id}/comments`);
      $(block).find('.answer').append($(newComment));
    }
  }

  function attachmentLinks(answer, block) {
    if (typeof answer.attachments !== 'undefined') {
      answer.attachments.forEach((attachment) => {
        const linkToFile = $('<a>').attr('href', attachment.url).text(attachment.filename);
        $(block).find('p:not(.answer-errors)').prepend(linkToFile);
      });
    }
  }

  function answerBlock(answer, block) {
    const link = $(block).find('.edit-answer-link');
    if (gon.user_id === answer.user_id) {
      link.next().attr('href', `/questions/${answer.question_id}/answers/${answer.id}`);

      $(block).find('form').attr({
        id: `edit-answer-${answer.id}`,
        action: `/questions/${answer.question_id}/answers/${answer.id}.js`,
      });
      $(block).find('#answer_body').text(answer.body);
      attachmentInputs(answer, block, $(block).find('.files'));
    } else {
      link.next().remove();
      link.remove();
      $(block).find('form').remove();
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

  $(document).on('turbolinks:load', () => {
    const questionId = $('.question').data('questionId');

    $(document).on('click', '.edit-answer-link', (e) => {
      e.preventDefault();
      $(e.target).hide();
      const answerId = $(e.target).closest('.answer').data('answerId');
      $(`form#edit-answer-${answerId}`).show();
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
            default: break;
          }
        },
      },
    );

    function errorsStr(errors) {
      let str = '';
      const capitalize = (s) => {
        if (typeof s !== 'string') return '';
        return s.charAt(0).toUpperCase() + s.slice(1)
      };
      for (const [key, value] of Object.entries(errors)) {
        str += `${capitalize(key)} ${value}`;
      }
      return str;
    }

    $(document).on('ajax:error', '#new_answer', (e) => {
      errorsStr(e.detail[0].errors);
      $(e.target).find('.answer-new-errors').text(errorsStr(e.detail[0].errors));
    }).on('ajax:error', 'form.edit_answer', (e) => {
      $(e.target).find('.answer-errors').text(errorsStr(e.detail[0].errors));
    });
  });
})(jQuery);
