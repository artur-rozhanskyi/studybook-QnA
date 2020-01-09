class SearchService
  def self.call(params)
    klass = params['search_in'] == 'all' ? ThinkingSphinx : params['search_in'].capitalize.constantize
    results = klass.search(Riddle::Query.escape(params['text']))
    results.group_by { |i| i.class.to_s.downcase }
  end
end
