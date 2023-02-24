module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    # include GraphQL::Types::Relay::HasNodeField
    # include GraphQL::Types::Relay::HasNodesField
    field :links, [Types::D3::LinkType]
    field :nodes, [Types::D3::NodeType]
    
    field :link, [Types::D3::LinkType], null: true do
      description "Find a link by id"
      argument :movie_id, ID
    end

    def link(movie_id)
      Link.where(movie_id)
    end


    def links
      pids = Person.find(500).id
      mids = Movie.find(628).id

      t= Link.where(person_id: [pids])
      .or(Link.where(movie_id: [mids])
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
