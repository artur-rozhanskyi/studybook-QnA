class AnswerForm < BaseForm
  validates :body, presence: true
end
