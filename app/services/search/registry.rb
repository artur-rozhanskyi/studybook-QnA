module Search
  class Registry
    INDEXES = {
      'question' => Search::Indexes::QuestionIndex,
      'answer' => Search::Indexes::AnswerIndex,
      'comment' => Search::Indexes::CommentIndex,
      'user' => Search::Indexes::UserIndex
    }.freeze

    def self.for(search_in)
      return INDEXES.values if search_in == 'all'

      Array(INDEXES[search_in])
    end

    def self.for_class_name(class_name)
      INDEXES.values.find { |index| index.model_class.name == class_name }
    end
  end
end
