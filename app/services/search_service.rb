class SearchService
  def self.call(params)
    Search::Query.new(
      text: params['text'].to_s,
      search_in: params['search_in'].to_s
    ).call
  end
end
