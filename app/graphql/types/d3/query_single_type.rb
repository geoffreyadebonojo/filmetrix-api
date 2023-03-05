# frozen_string_literal: true

module Types
  class D3::QuerySingleType < Types::BaseObject
    field :ids, [String]
    field :nodes, [Types::D3::NodeType]
    field :links, [Types::D3::LinkType]

    def nodes
      object[:nodes]
    end
    
    def links
      object[:links]
    end


    # field :anchor, Types::D3::DetailType
    # field :credits, [Types::D3::NodeType]

    # def anchor
    #   object[:anchor]
    # end
    
    # def credits
    #   object[:credits]
    # end
  end
end
