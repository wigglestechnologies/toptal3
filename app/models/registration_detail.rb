class RegistrationDetail < ApplicationRecord
  validates :email, length: { maximum: STRING_MAX_LIMIT }, format: { with: REGEX_EMAIL }
  validates :token, presence: true
  validates :valid_until, presence: true
  before_save do self.email&.downcase! end
end
