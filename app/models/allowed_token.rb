class AllowedToken < ApplicationRecord
  validates :encrypted_token, presence: true
  validates :user_id, presence: true
  validates :expired_at, presence: true
end
