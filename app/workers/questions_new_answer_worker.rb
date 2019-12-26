class QuestionsNewAnswerWorker < BaseWorker
  def perform(id)
    question = Question.find(id)
    QuestionsMailer.author_new_answer(question).deliver
    question.subscribed_users.find_each do |user|
      QuestionsMailer.subscribed_user(user, question).deliver
    end
  end
end
