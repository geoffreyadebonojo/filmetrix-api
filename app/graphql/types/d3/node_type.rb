# frozen_string_literal: true

module Types
  class D3::NodeType < Types::BaseObject
    field :id, String
    field :name, String
    field :poster, String

    def id
      object.full_id
    end

    def name
      object.name
    end

    def poster
      poster = object.poster
      poster.nil? ? "" : root+poster
    end

    def root
      "https://image.tmdb.org/t/p/w185_and_h278_bestv2"
    end
  end
end
