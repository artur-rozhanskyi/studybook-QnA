class QuestionsMailer < ApplicationMailer
  def author_new_answer(question)
    @question = question

    mail to: question.user.email, subject: 'New answer'
  end

  def subscribed_user(user, question)
    @question = question
    @user = user

    mail to: user.email, subject: 'New answer'
  end
end
