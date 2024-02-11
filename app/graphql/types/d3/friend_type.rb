# frozen_string_literal: true

module Types
  class D3::FriendType < Types::BaseObject
    field :email, String
    field :profile_img, String
  end

  def email
    object[:email]
  end

  def profile_img
    object[:profile_img]
  end
end
