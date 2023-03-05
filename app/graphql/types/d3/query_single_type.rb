# frozen_string_literal: true

module Types
  class D3::QuerySingleType < Types::BaseObject
    field :id, String
    field :anchor, Types::D3::DetailType
    field :credits, [Types::D3::NodeType]

    def anchor
      object[:anchor]
    end
    
    def credits
      object[:credits]
    end
  end
end
