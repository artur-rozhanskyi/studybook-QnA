require 'application_responder'

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  protect_from_forgery

  self.responder = ApplicationResponder
  respond_to :html

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  rescue_from Pundit::NotAuthorizedError do |exception|
    redirect_to root_path, alert: exception.message, status: :unauthorized
  end

  protected

  def record_not_found
    render file: Rails.public_path.join('404'), layout: false, status: :not_found
  end
end
