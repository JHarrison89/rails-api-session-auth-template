class User < ApplicationRecord
  has_secure_password

  validates :username, uniqueness: true, presence: true
  validates :password, presence: true

  def self.authenticate(username, password)
    user = User.find_by(username: username)
    user && user.authenticate(password)
  end

end
