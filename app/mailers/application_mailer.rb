class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: 'qna@qna.com'
  layout 'mailer'
end
