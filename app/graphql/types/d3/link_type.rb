# frozen_string_literal: true

module Types
  class D3::LinkType < Types::BaseObject
    field :id, ID
    field :source, String
    field :target, String
    field :roles, [String]

    def source
      object[:source]
    end
    
    def target
      object[:target]
    end
  end
end
