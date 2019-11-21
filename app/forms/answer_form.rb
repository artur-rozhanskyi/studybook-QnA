class AnswerForm < BaseForm
  validates :body, presence: true

  delegate  :user_id, :question_id, to: :object

  def initialize(object = nil)
    @body = object.body if object
    super
  end

  def object
    @object ||= Answer.new
  end
end
