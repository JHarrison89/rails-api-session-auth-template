# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'myrailsmail@gmail.com'
  layout 'mailer'
end
