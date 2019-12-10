class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :role, :profile

  has_one :profile, serializer: ProfileSerializer
end
