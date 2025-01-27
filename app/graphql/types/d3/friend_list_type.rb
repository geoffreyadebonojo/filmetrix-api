# frozen_string_literal: true

module Types
  class D3::FriendListType < Types::BaseObject
    field :friends, [Types::D3::FriendType]
  end
end
