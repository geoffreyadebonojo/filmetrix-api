# frozen_string_literal: true

module Types
  class D3::SavedGraphType < Types::BaseObject
    field :slug, String
    field :posters, [String]

    def slug
      object[:slug]
    end 
    
    def posters
      object[:posters]
    end
  end
end
