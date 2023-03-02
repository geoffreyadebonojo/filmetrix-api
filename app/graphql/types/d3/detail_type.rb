# frozen_string_literal: true

module Types
  class D3::DetailType < Types::BaseObject
    field :id, String
    # field :also_known_as, [String]
    field :summary, String
    field :year, String
    # field :deathday, String
    # field :homepage, String
    field :imdb_id, String
    field :name, String
    # field :known_for_department, String
    # field :place_of_birth, String
    field :popularity, Float
    field :poster, String

    def id
      [object[:media_type], object[:id]].join("-")
    end

    # def also_known_as
    #   object[:also_known_as]
    # end

    def summary
      object[:biography] || object[:overview]
    end

    def year
      # get more specific?
      # Birthday popover??
      date = object[:birthday] || object[:release_date] || object[:first_air_date]
      Date.parse(date).year
    end

    # def deathday
    #   if object[:deathday].present?
    #     Date.parse(object[:deathday]).year
    #   end
    # end

    # def homepage
    #   object[:homepage]
    # end

    def imdb_id
      if object[:media_type] == "person"
        imdb_root = "https://www.imdb.com/name/"
      else
        imdb_root = "https://www.imdb.com/title/"
      end
      imdb_root + object[:imdb_id]
    end

    def name
      object[:name] || object[:title]
    end

    # def known_for_department
    #   object[:known_for_department]
    # end

    # def place_of_birth
    #   object[:place_of_birth]
    # end

    def popularity
      object[:popularity]
    end

    def poster
      poster = object[:profile_path] || object[:poster_path]
      poster.nil? ? "" : root+poster
    end

    def root
      "https://image.tmdb.org/t/p/w185_and_h278_bestv2"
    end
  end
end


