module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    # include GraphQL::Types::Relay::HasNodeField
    # include GraphQL::Types::Relay::HasNodesField
    # field :links, [Types::D3::LinkType]
    field :nodes, [Types::D3::NodeType], null: true do
      argument :movie_ids, [ID]
      argument :person_ids, [ID]
      argument :count, Integer
    end

    field :links, [Types::D3::LinkType], null: true do
      argument :movie_ids, [ID]
      argument :person_ids, [ID]
      argument :count, Integer
    end

    def assembler(args)
      person_ids = args[:person_ids]
      movie_ids = args[:movie_ids]
      count = args[:count]

      people = Person.where(id: person_ids)
      movies = Movie.where(id: movie_ids)
      
      a = []
      a << people
      people.each do |person|
        a << person.movies.order(vote_count: :desc).first(count)
      end

      a << movies

      movies.map do |movie|
        a << movie.people.first(count)
      end

      a.flatten(3)
    end


    def links(args)
      nodes = assembler(args)

      links = nodes.map{ |x|
        y = x.links.first(args[:count]).map { |z|
          next if z.person_id.nil? || z.movie_id.nil?

          index = nodes.map{ |x| "#{x.media_type}-#{x.id}"}

          pid = "person-#{z.person_id}"
          next unless index.include?(pid)
          
          mid = "movie-#{z.movie_id}"
          next unless index.include?(mid)
          
          {
            source: pid,
            target: mid,
            roles: z.roles.reject(&:empty?)
          }
        }
      }.flatten(3).compact.uniq

      return links
    end
    
    def nodes(args)
      nodes = assembler(args).uniq

      return nodes
    end
  end
end
