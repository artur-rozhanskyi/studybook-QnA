class QuestionForm < BaseForm
  validates :body, :title, presence: true
end
