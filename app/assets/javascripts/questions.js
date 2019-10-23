$(document).on('turbolinks:load', function() {
  $(document).on('click', '.del_file', function (e) {
    e.preventDefault();
    $(this).parent().remove();
  });

  $('.add_file').click(function () {
    if ($(".files").children().size() < 10) {
      div_clone = $(".files").children('.file').last().clone();
      new_attributes(div_clone);
      button_for_delete(div_clone);
      $('.files').append(div_clone);
    }
  });

  function incrementString(str) {
    return str.replace(/\d/, function (s) {
      return parseInt(s) + 1;
    });
  }

  function button_for_delete(parent) {
    button = $('<button>', { text: "Delete file", class: "del_file"});
    last_tag_name = parent.children().last().prop("tagName");
    if(last_tag_name === "INPUT") {
      $(parent).append(button);
    }
  }

  function new_attributes(parent) {
    label = parent.children().first();
    input = parent.children().first().next();
    input_attr_id = input.attr('id');
    input_attr_name = input.attr('name');
    label_attr_for = label.attr('for');
    var new_array = [input_attr_id, input_attr_name, label_attr_for].map(function (attr) {
      return incrementString(attr);
    });
    input.attr('id', new_array[0]);
    input.attr('name', new_array[1]);
    label.attr('for', new_array[2]);
  }
});
