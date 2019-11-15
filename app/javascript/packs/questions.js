$(document).on('turbolinks:load', function () {
  $(document).on('click', '.del_file', function (e) {
    e.preventDefault()
    $(this).parent().remove()
  })

  $(document).on('click', '.add_file', function () {
    if ($(this).closest('form').children('.files').children().size() < 10) {
      div_clone = $(this).closest('form').children('.files').children('.file').last().clone()
      new_attributes(div_clone)
      button_for_delete(div_clone)
      $(this).closest('form').children('.files').append(div_clone)
    }
  })

  PrivatePub.subscribe('/questions', function (data, chanel) {
    var action = data.action
    var question = data.question
    switch (action) {
      case 'create': $('table tr:last').after(question_block(question)); break
      case 'update': update_question(question); break
      case 'destroy' : $('.field').first().css('text-decoration', 'line-through'); break
    }
  })

  function incrementString (str) {
    return str.replace(/\d/, function (s) {
      return parseInt(s) + 1
    })
  }

  function button_for_delete (parent) {
    var button = $('<button>', { text: 'Delete file', class: 'del_file' })
    last_tag_name = parent.children().last().prop('tagName')
    if (last_tag_name === 'INPUT') {
      $(parent).append(button)
    }
  }

  function new_attributes (parent) {
    var label = parent.children().first()
    var input = parent.children().first().next()
    var input_attr_id = input.attr('id')
    var input_attr_name = input.attr('name')
    var label_attr_for = label.attr('for')
    var new_array = [input_attr_id, input_attr_name, label_attr_for].map(function (attr) {
      return incrementString(attr)
    })
    input.val('')
    input.attr('id', new_array[0])
    input.attr('name', new_array[1])
    label.attr('for', new_array[2])
  }

  function update_question (question) {
    var title = $('.field').first()
    $(title).find('.inline').text(question.title)
    $(title).next().find('.inline').text(question.body)
    $('.question ul').text('')
    question.attachments.forEach(function (attachment) {
      $('.question ul').append($('<li>').append($('<a>').attr('href', attachment.url).text(attachment.filename)))
    })
  }

  function question_block (question) {
    return $('<tr>').addClass('question')
      .append($('<td>').append(question.title))
      .append($('<a>').attr('href', '/questions/' + question.id).text('Show'))
  }
})
