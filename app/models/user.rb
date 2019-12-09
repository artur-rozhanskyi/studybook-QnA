class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:facebook, :twitter, :google_oauth2]

  has_many :questions, dependent: :nullify
  has_many :answers, dependent: :nullify
  has_many :comments, dependent: :nullify
  has_many :authorizations, dependent: :destroy
  has_one :profile, dependent: :destroy

  def self.find_for_oauth(params)
    auth = Authorization.find_by(provider: params.provider, uid: params.uid.to_s)
    return auth.user if auth

    email = params.info[:email]
    user = User.find_by(email: email)
    user ? user.create_authorization(params) : user = create_user_by_authorization(params)
    user
  end

  def create_authorization(params)
    authorizations.create(provider: params.provider, uid: params.uid)
  end

  def self.create_user_by_authorization(params)
    password = Devise.friendly_token[0, 20]
    user = User.create!(email: params.info[:email], password: password, password_confirmation: password)
    user.create_authorization params
    user.create_profile(first_name: params.info[:first_name], last_name: params.info[:last_name])
    user
  end
end
