# frozen_string_literal: true

module Types
  class D3::NodeType < Types::BaseObject
    field :id, String
    field :name, String
    field :poster, String
    field :type, [String]
    field :entity, String
    field :year, String
    field :known_for_department, String

    def id
      object[:id]
    end

    def name
      object[:name]
    end
    
    def poster
      poster = object[:poster]
      poster.nil? ? "" : root+poster
    end
    
    def type
      object[:type]
    end
    
    def entity
      # object[:entity]
      object[:id].split("-")[0]
    end

    def year
      object[:year]
    end

    def known_for_deparment
      object[:known_for_deparment]
    end

    def root
      "https://image.tmdb.org/t/p/w185_and_h278_bestv2"
    end
  end
end
