$(document).on('turbolinks:load', function() {
  $(document).on('click', '.edit-answer-link', function(e) {
    e.preventDefault();
    $(this).hide();
    var answer_id = $(this).data('answerId');
    $('form#edit-answer-' + answer_id).show();
  });

  $(document).on('ajax:success', 'form.edit_answer', function(e) {
    var answer = $.parseJSON(e.detail[2].responseText);
    var prev_elem = $(this).parent().prev();
    $(this).parent().remove();
    if(prev_elem.length === 0){
      $('.answers').prepend(answer_block(answer, tmpl.content.cloneNode(true)));
    }
    else {
      $(prev_elem).after(answer_block(answer, tmpl.content.cloneNode(true)));
    }
  })
    .on('ajax:error', 'form.edit_answer', function(event, xhr, data, status) {
      $(this).find('.answer-errors').text(event.detail[0]);
    });

  $(document).on('ajax:success', '#new_answer', function(e) {
    var answer = $.parseJSON(e.detail[2].responseText);
    $('.answers').append(answer_block(answer, tmpl.content.cloneNode(true)));
    $('#answer_body').val('');
    $('#new_answer input').val('');
    $('#new_answer .file:not(:first-child)').remove();
  })
    .on('ajax:error', '#new_answer', function(e){
      $(this).find('.answer-new-errors').text(e.detail[0]);
    });

  function answer_block(answer, block) {
    var link = $(block).find('.edit-answer-link');
    link.attr('data-answer-id', answer.id);
    link.next().attr('href', '/questions/'+ answer.question_id +'/answers/' + answer.id);
    attachment_links(answer, block);
    $(block).find('#ans_body').prepend(answer.body);

    $(block).find('form').attr({ 'id': 'edit-answer-' + answer.id,
                                  'action': '/questions/'+ answer.question_id +'/answers/' + answer.id + '.json'} );
    $(block).find('#answer_body').text(answer.body);
    attachment_inputs(answer, block, $(block).find('.files'));
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
    answer.attachments.forEach(function (attachment, index) {
      files_block.append(file_block(attachment, index));
    });
    $(block).find('form .files').append(input_block(answer.attachments.length));
  }

  function attachment_links(answer, block) {
    answer.attachments.forEach(function (attachment) {
      link_to_file = $('<a>').attr('href', attachment.url).text(attachment.filename);
      $(block).find('p:not(.answer-errors)').prepend(link_to_file);
    });
  }
});
