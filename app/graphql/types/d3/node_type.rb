# frozen_string_literal: true

module Types
  class D3::NodeType < Types::BaseObject
    field :entity, String
    field :id, String
    field :name, String
    field :poster, String
    field :type, [String]
    field :year, String
    field :popularity, Float
    field :vote_count, Integer
    field :vote_average, Float
    field :known_for_department, String

    def entity
      # object[:entity]
      object[:id].split("-")[0]
    end

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

    ##########

    def year
      object[:year]
    end

    def popularity
      object[:score].fetch(:popularity)
    end
    
    def vote_average
      object[:score].fetch(:vote_average, 0)
    end

    def vote_count
      object[:score].fetch(:vote_count, 0)
    end

    def known_for_deparment
      object[:known_for_deparment]
    end

    def root
      "https://image.tmdb.org/t/p/w185_and_h278_bestv2"
    end
  end
end
