# frozen_string_literal: true

module Types
  class D3::DetailType < Types::BaseObject
    field :id, String
    field :also_known_as, [String]
    field :biography, String
    field :birthday, String
    field :deathday, String
    field :homepage, String
    field :imdb_id, String
    field :name, String
    field :known_for_department, String
    field :place_of_birth, String
    field :popularity, Float
    field :poster, String

    def id
      [object[:media_type], object[:id]].join("-")
    end

    def also_known_as
      object[:also_known_as]
    end

    def biography
      object[:biography]
    end

    def birthday
      object[:birthday]
    end

    def deathday
      object[:deathday]
    end

    def homepage
      object[:homepage]
    end

    def imdb_id
      object[:imdb_id]
    end

    def name
      object[:name]
    end

    def known_for_department
      object[:known_for_department]
    end

    def place_of_birth
      object[:place_of_birth]
    end

    def popularity
      object[:popularity]
    end

    def poster
      poster = object[:profile_path]
      poster.nil? ? "" : root+poster
    end

    def root
      "https://image.tmdb.org/t/p/w185_and_h278_bestv2"
    end
  end
end


