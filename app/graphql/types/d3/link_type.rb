# frozen_string_literal: true

module Types
  class D3::LinkType < Types::BaseObject
    field :id, ID, null: false
    field :source, Integer
    field :target, Integer
    field :roles, [String]

    def source 
      object.person_id
    end
    
    def target
      object.movie_id
    end
  end
end
