# frozen_string_literal: true

module Types
  class D3::LinkType < Types::BaseObject
    field :id, ID

    field :mid, ID
    field :source, Integer
    field :target, Integer
    field :roles, [String]

    def source 
      object[:source]
    end
    
    def target
      object[:target]
    end
  end
end
