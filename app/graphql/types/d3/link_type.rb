# frozen_string_literal: true

module Types
  class D3::LinkType < Types::BaseObject
    field :id, ID, null: false
    field :roles, [String]

    field :source, Integer
    def source 
      object.person_id
    end
    
    field :target, Integer
    def target
      object.movie_id
    end
  end
end
