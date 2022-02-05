class ApplicationMailer < ActionMailer::Base
  default from: MAIL_SENDER
  layout 'mailer'
end
