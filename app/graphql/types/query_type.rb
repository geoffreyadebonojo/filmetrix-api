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

    def links(args)
      nodes = nodes(args)

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
      n = assembler(args).uniq
      # nodes = []
      # n.filter{|x|x[:media_type]=="person"}.each { |pe|
      #   nodes << pe
      #   nodes << pe.movies.first(args[:count])
      # }
      # n.filter{|x|x[:media_type]!="person"}.each { |m|
      #   nodes << m
      #   nodes << m.people.first(args[:count])
      # }
      # return nodes.flatten(3).compact.uniq
      return n
    end

    private

    def assembler(args)
      person_ids = args[:person_ids]
      movie_ids = args[:movie_ids]
      count = args[:count]

      people = []
      movies = []

      person_ids.map do |person_id|
        if Person.exists?(person_id)
          people << Person.find(person_id)
        else
          TmdbService.person_credits(person_id[:id])
          people << TmdbService.person_details(person_id[:id])
        end
      end.flatten(2)

      movie_ids.map do |movie_id|
        if Movie.exists?(movie_id)
          movies << Movie.find(movie_id)
        else
          TmdbService.movie_credits(movie_id[:id])
          movies << TmdbService.movie_details(movie_id[:id])
        end
      end.flatten(2)

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
  end
end
