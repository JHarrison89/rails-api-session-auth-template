class User < ApplicationRecord
  has_secure_password

  validates :username, :email, uniqueness: true, presence: true
  validates :password, presence: true

  def self.authenticate(username, password)
    binding.pry
    user = User.find_by(username: username)
    user && user.authenticate(password)
  end

  def self.reset_password!(password)
    password = password
    save!
   end

end
