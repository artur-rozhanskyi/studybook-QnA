class QuestionForm < BaseForm
  attr_accessor :title

  validates :body, :title, presence: true

  delegate :answers, to: :object

  def object
    @object ||= Question.new
  end

  def submit(attributes)
    self.title = attributes[:title]
    super
  end
end
