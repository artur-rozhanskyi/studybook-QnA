class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  protected

  def handle_record_not_found
    render file: Rails.root.join('public', '404'), layout: false, status: 404
    false
  end
end
