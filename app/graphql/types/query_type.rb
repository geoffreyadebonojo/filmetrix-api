module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    # include GraphQL::Types::Relay::HasNodeField
    # include GraphQL::Types::Relay::HasNodesField
    field :links, [Types::D3::LinkType]
    field :nodes, [Types::D3::NodeType]

    def links
      pids = [500]
      mids = [137113, 75612, 56292]

      t= Link.where(person_id: pids)
      .or(Link.where(movie_id: mids)
      ).map do |x|
        j = index.find_index("person-#{x.person_id}")
        k = index.find_index("movie-#{x.movie_id}")
        next if j.nil? || k.nil?

        {
          source: j,
          target: k,
          roles: x.roles.reject(&:empty?)
        }
      end.compact
    end

    def index
      nodes.map do |x|
        "#{x.media_type}-#{x.id}"
      end
    end
    
    def nodes
      [Person.all, Movie.all].flatten
    end
  end
end
