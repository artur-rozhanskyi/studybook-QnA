function updateQuestion(question) {
  const title = $('.field').first();
  $(title).find('.inline').text(question.title);
  $(title).next().find('.inline').text(question.body);
  $('.question ul').text('');
  question.attachments.forEach((attachment) => {
    $('.question ul').append($('<li>').append($('<a>')
      .attr('href', attachment.url).text(attachment.filename)));
  });
}

function questionBlock(question) {
  return $('<tr>').addClass('question')
    .append($('<td>').append(question.title))
    .append($('<a>').attr('href', `/questions/${question.id}`).text('Show'));
}

function buttonForDelete(parent) {
  const button = $('<button>', { text: 'Delete file', class: 'del_file' });
  const lastTagName = parent.children().last().prop('tagName');
  if (lastTagName === 'INPUT') {
    $(parent).append(button);
  }
}

function newAttributes(parent) {
  const label = parent.children().first();
  const input = parent.children().first().next();
  const incrementString = (str) => {
    str.replace(/\d/, (s) => (parseInt(s, 10) + 1));
  };
  const newArray = [input.attr('id'), input.attr('name'), label.attr('for')].map((attr) => incrementString(attr));
  input.val('');
  input.attr({
    id: newArray[0],
    name: newArray[1],
    for: newArray[2],
  });
}

function buttonAdd(e) {
  const divClone = $(e.target).closest('form').children('.files').children('.file')
    .last()
    .clone();
  newAttributes(divClone);
  buttonForDelete(divClone);
  $(e.target).closest('form').children('.files').append(divClone);
}

(($) => {
  $(document).on('turbolinks:load', () => {
    $(document).on('click', '.del_file', (e) => {
      e.preventDefault();
      $(e.target).parent().remove();
    });

    $(document).on('click', '.add_file', (e) => {
      if ($(e.target).closest('form').children('.files').children().length < 10) {
        buttonAdd(e);
      }
    });

    App.cable.subscriptions.create('QuestionsChannel', {
      received(data) {
        const { question, action } = data;

        switch (action) {
          case 'create':
            $('table tr:last').after(questionBlock(question));
            break;
          case 'update':
            updateQuestion(question);
            break;
          case 'destroy':
            $('.field').first().css('text-decoration', 'line-through');
            break;
          default: break;
        }
      },
    });
  });
})(jQuery);
