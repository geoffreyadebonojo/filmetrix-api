# frozen_string_literal: true

module Types
  class D3::GraphEntityType < Types::BaseObject
    field :ids, [String]
    field :id, String
    field :nodes, [Types::D3::NodeType]
    field :links, [Types::D3::LinkType]

    def ids
      object[:ids]
    end

    def id
      object[:id]
    end

    def nodes
      object[:nodes]
    end
    
    def links
      object[:links]
    end
  end
end
