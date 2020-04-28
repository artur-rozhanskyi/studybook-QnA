class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:facebook, :twitter, :google_oauth2]

  # after_save ThinkingSphinx::RealTime.callback_for(:user)

  has_many :questions, dependent: :nullify
  has_many :answers, dependent: :nullify
  has_many :comments, dependent: :nullify
  has_many :authorizations, dependent: :destroy
  has_one :profile, dependent: :destroy

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all,
           inverse_of: :users

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all,
           inverse_of: :users

  has_and_belongs_to_many :subscribed_questions, class_name: 'Question'

  delegate :first_name, :last_name, to: :profile, allow_nil: true

  enum role: { user: 0, admin: 1 }

  def question_subscribed?(question)
    subscribed_questions.include?(question)
  end

  def create_authorization(params)
    authorizations.create(provider: params.provider, uid: params.uid)
  end

  class << self
    def create_user_by_authorization(params)
      password = Devise.friendly_token[0, 20]
      user = User.create!(email: params.info[:email], password: password, password_confirmation: password)
      user.create_authorization params
      user.create_profile(first_name: params.info[:first_name], last_name: params.info[:last_name])
      user
    end

    def find_for_oauth(params)
      auth = Authorization.find_by(provider: params.provider, uid: params.uid.to_s)
      return auth.user if auth

      email = params.info[:email]
      user = User.find_by(email: email)
      user ? user.create_authorization(params) : user = create_user_by_authorization(params)
      user
    end
  end
end
