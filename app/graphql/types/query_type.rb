module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    # include GraphQL::Types::Relay::HasNodeField
    # include GraphQL::Types::Relay::HasNodesField
    field :links, [Types::D3::LinkType]
    field :nodes, [Types::D3::NodeType]
    
    field :link, [Types::D3::LinkType], null: true do
      description "Find a link by id"
      argument :movie_ids, [ID]
      argument :person_ids, [ID]
    end

    def link(args)
      set_index = node_index_for_network(args)

      Link.where(person_id: args[:person_ids])
      .or(Link.where(movie_id: args[:movie_ids])
      ).map do |x|
        j = set_index.find_index("person-#{x.person_id}")
        k = set_index.find_index("movie-#{x.movie_id}")
        next if j.nil? || k.nil?

        {
          source: j,
          target: k,
          roles: x.roles.reject(&:empty?)
        }
      end.compact
    end

    def node_index_for_network(ids=[])
      selected_nodes(ids).map { |x| 
        "#{x.media_type}-#{x.id}"
      }
    end
    
    def selected_nodes(ids)
      movie_ids = ids[:movie_ids]
      person_ids = ids[:person_ids]
      return [
        Person.where(id: person_ids),
        Movie.where(id: movie_ids)
      ].flatten
    end

    def links
      pids = Person.all.pluck(:id)
      mids = Movie.all.pluck(:id)

      t= Link.where(person_id: pids)
      .or(Link.where(movie_id: mids)
      ).first(20)
      
      t.map do |x|
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
      # [Person.all, Movie.all].flatten
      [Person.all, Movie.first(20)].flatten
    end
  end
end
