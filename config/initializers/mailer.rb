# encoding: utf-8
MAIL_SENDER = 'homprojecteinfo@gmail.com'
MAIL_PASSWORD = 'Takehome123'

Rails.application.configure do

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => 'api.bccftools.com' }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => MAIL_SENDER,
      :password             => MAIL_PASSWORD,
      :authentication       => 'plain',
      :enable_starttls_auto => true
  }
end
