# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, uniqueness: true,
                       length: { minimum: 3, maximum: 200 }, presence: true
  validates :password, length: { minimum: 8, maximum: 200 }, presence: true
  validate :password_requirements_are_met
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP, uniqueness: true, presence: true
  # URI::MailTo::EMAIL_REGEXP does not check any domain i.e .com, .co.uk etc

  def self.authenticate(username, password)
    user = User.find_by(username: username)
    user&.authenticate(password)
  end

  def reset_password!(password)
    @password = password #instance variable is accessable by password_requirements_are_met
    save!
  end

  def password_requirements_are_met
    rules = {
      'must contain at least one lowercase letter' => /[a-z]+/,
      'must contain at least one uppercase letter' => /[A-Z]+/,
      'must contain at least one digit' => /\d+/,
      'must contain at least one special character' => /[^A-Za-z0-9]+/
    }

    rules.each do |message, regex|
      errors.add(:password, message) unless @password.match(regex)
    end
  end
end
