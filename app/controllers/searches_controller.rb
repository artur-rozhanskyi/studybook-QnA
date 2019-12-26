class SearchesController < ApplicationController
  def show
    @resulting = SearchService.call search_params if search_params[:search_in].present?
  end

  private

  def search_params
    params.permit(:text, :search_in)
  end
end
