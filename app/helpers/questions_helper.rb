module QuestionsHelper
  def subscribes_button(user, question)
    visibility = user.question_subscribed?(question)

    button_with_visibility_to('Unsubscribe', unsubscribe_question_path(question), visibility, klass: 'unsubscribe') +
      button_with_visibility_to('Subscribe', subscribe_question_path(question), !visibility, klass: 'subscribe')
  end

  private

  def button_with_visibility_to(text, url, visibility, klass:)
    invisible_class = 'invisible' unless visibility

    button_to(text,
              url,
              method: :post,
              remote: true,
              form: { "data-type": 'json',
                      class: "#{klass} #{invisible_class}" })
  end
end
