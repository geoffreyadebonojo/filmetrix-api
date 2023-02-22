# frozen_string_literal: true

module Types
  class D3::NodeType < Types::BaseObject
    field :_id, String
    field :name, String
    field :poster, String

    def _id
      object.full_id
    end

    def name
      object.name
    end

    def poster
      object.poster
    end
  end
end
