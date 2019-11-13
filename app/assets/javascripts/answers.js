$(document).on('turbolinks:load', function() {
  questionId = $('.question').data('questionId');

  $(document).on('click', '.edit-answer-link', function(e) {
    e.preventDefault();
    $(this).hide();
    var answer_id = $(this).closest('.answer').data('answerId');
    $('form#edit-answer-' + answer_id).show();
  });

  PrivatePub.subscribe('/question/' + questionId + '/answers', function(data, chanel) {
    var answer = data['answer'];
    var action = data['action'];

    switch(action) {
      case 'create': new_answer(answer); break;
      case 'update': update_answer(answer); break;
      case 'destroy': destroy_answer(answer); break;
    }
  });

  $(document).on('ajax:error', '#new_answer', function(e){
      $(this).find('.answer-new-errors').text(e.detail[0]);
    }).on('ajax:error', 'form.edit_answer', function(event, xhr, data, status) {
    $(this).find('.answer-errors').text(event.detail[0]);
  });

  function new_answer(answer) {
    $('.answers').append(answer_block(answer, tmpl.content.cloneNode(true)));
    $('#answer_body').val('');
    $('#new_answer input').val('');
    $('#new_answer .file:not(:first-child)').remove();
  }

  function update_answer(answer) {
    var prev_elem = $('*[data-answer-id="'+ answer.id +'"]').prev();
    $('*[data-answer-id="'+ answer.id +'"]').remove();
    if(prev_elem.length === 0){
      $('.answers').prepend(answer_block(answer, tmpl.content.cloneNode(true)));
    }
    else {
      $(prev_elem).after(answer_block(answer, tmpl.content.cloneNode(true)));
    }
  }

  function destroy_answer(answer) {
    $('*[data-answer-id="' + answer.id + '"]').remove();
  }

  function answer_comments(answer, block) {
    answer.comments.forEach(function(comment){
      $(block).find('.comments').append(comment_block(comment));
    });
    if (typeof(gon.user_id) !== 'undefined') {
      new_comment = new_comment_form.content.cloneNode(true);
      $(new_comment).find('#new_comment_answer')
        .attr('action', "/questions/" + answer.question_id + "/answers/" + answer.id + "/comments");
      $(block).find(".answer").append($(new_comment));
    }
  }

  function answer_block(answer, block) {
    var link = $(block).find('.edit-answer-link');
    if (gon.user_id === answer.user_id){
      var link = $(block).find('.edit-answer-link');
      link.next().attr('href', '/questions/'+ answer.question_id +'/answers/' + answer.id);

      $(block).find('form').attr({ 'id': 'edit-answer-' + answer.id,
                                   'action': '/questions/'+ answer.question_id +'/answers/' + answer.id + '.js'} );
      $(block).find('#answer_body').text(answer.body);
      attachment_inputs(answer, block, $(block).find('.files'));
    }
    else {
      link.next().remove();
      link.remove();
      $(block).find('form').remove();
    }

    $(block).find('.answer').attr('data-answer-id', answer.id);
    answer_comments(answer, block);
    attachment_links(answer, block);

    $(block).find('#ans_body').prepend(answer.body);

    return block;
  }

  function file_block(attachment, index) {
    var div = $('<div>');
    div.append($('<p>').append($('<a>').attr('href', attachment.url).text(attachment.filename)));
    var input_hidden_label = $('<input>').attr({ 'name': 'answer[attachments_attributes][' + index +'][_destroy]',
      'type': 'hidden',
      'value': 0});
    var input_hidden = $('<input>').attr({ 'name': 'answer[attachments_attributes][' + index +'][id]',
      'type': 'hidden',
      'value': attachment.id,
      'id': 'answer[attachments_attributes][' + index +'][id]'});
    var input_checkbox_label = $('<input>').attr({ 'name': 'answer[attachments_attributes][' + index +'][_destroy]',
      'type': 'checkbox',
      'id': 'answer_attachments_attributes_' + index +'__destroy'});
    $('<label>').attr('for', 'answer_attachments_attributes_' + index + '__destroy')
      .text('Remove file')
      .prepend(input_checkbox_label)
      .prepend(input_hidden_label)
      .appendTo(div);
    return div.append(input_hidden);
  }

  function input_block(index) {
    var div = $('<div>').attr('class', 'file');
    var input_file = $('<input>').attr({ 'name': 'answer[attachments_attributes][' + index +'][file]',
      'type': 'file',
      'value': '',
      'id': 'answer_attachments_attributes_' + index +'_file'});
    var label = $('<label>').attr('for', 'answer_attachments_attributes_' + index + '_file').text('File');
    return div.append(label).append(input_file);
  }

  function attachment_inputs(answer, block, files_block) {
    if (typeof answer.attachments !== 'undefined') {
      answer.attachments.forEach(function (attachment, index) {
        files_block.append(file_block(attachment, index));
      });
      $(block).find('form .files').append(input_block(answer.attachments.length));
    }
  }

  function attachment_links(answer, block) {
    if (typeof answer.attachments !== 'undefined') {
      answer.attachments.forEach(function (attachment) {
        link_to_file = $('<a>').attr('href', attachment.url).text(attachment.filename);
        $(block).find('p:not(.answer-errors)').prepend(link_to_file);
      });
    }
  }
});
