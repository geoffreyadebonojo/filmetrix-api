class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :profile_img, :created_at
end
