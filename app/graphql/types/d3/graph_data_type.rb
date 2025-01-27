# frozen_string_literal: true

module Types
  class D3::GraphDataType < Types::BaseObject
    field :graphEntities, [Types::D3::GraphEntityType]

    def nodes
      object[:nodes]
    end
    
    def links
      object[:links]
    end
  end
end
