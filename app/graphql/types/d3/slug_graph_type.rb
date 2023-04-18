# frozen_string_literal: true

module Types
  class D3::SlugGraphType < Types::BaseObject
    field :existing, [[String]]
    field :data, [Types::D3::GraphEntityType]

    def existing
      object.existing
    end 
    
    def data
      object.data
    end
  end
end
