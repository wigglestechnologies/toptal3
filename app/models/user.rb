class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :full_name, length: { maximum: STRING_MAX_LIMIT }
  validates :email, presence: true, length: { maximum: STRING_MAX_LIMIT }, format: { with: REGEX_EMAIL}

  validates :password, presence: true,
            length: { minimum: STRING_MIN_LIMIT, maximum: STRING_MAX_LIMIT }, if: -> {new_record? || changes[:crypted_password]}

  validate  :password_requirements_are_met, if: -> {new_record? || changes[:crypted_password]}
  validates :crypted_password, presence: true, length: { maximum: STRING_MAX_LIMIT }

  enum role: [:regular, :manager, :admin]

  after_initialize :set_default_role, if: :new_record?
  before_save do self.email&.downcase! end

  private
  def set_default_role
    self.role ||= :regular
  end

  def password_requirements_are_met
    return false if self.password.nil?
    error_text_prefix = " must contain at least "
    error_text = ''
    rules = {
        "one lowercase letter"  => /[a-z]+/,
        "one uppercase letter"  => /[A-Z]+/,
        "one digit"             => /\d+/,
        "one special character" => /[^A-Za-z0-9]+/
    }

    rules.each do |message, regex|
      unless self.password.match( regex )
        error_text += error_text_prefix + message
        error_text_prefix = ', '
      end
    end
    errors.add( :password, error_text ) unless error_text.blank?
  end
end
