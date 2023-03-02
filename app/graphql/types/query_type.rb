require "ostruct"

module Types
  class QueryType < Types::BaseObject
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
    
    field :search, [Types::D3::NodeType], null: true do
      argument :term, String
    end

    field :details, Types::D3::DetailType, null: true do
      argument :id, ID
      argument :entity, String
    end

    def details(args)
      id = args[:id]
      entity = args[:entity]

      if entity == 'person'
        TmdbService.person_details(id)
      else
        TmdbService.movie_details(id)
      end
    end
    
    def search(args)
      # body = eval(File.read('./db/person-500-search-result.json'))
      # x= TmdbService.build_from_results(search_result)

      # api_hit = false
      # tag = "search-#{args[:term]}"

      # results = Rails.cache.fetch(tag) do
      #   api_hit = true
      results = TmdbService.search(args[:term])
      # end

      # if api_hit
      #   puts ">>>>>>>>>> API HIT on #{tag} <<<<<<<<<"
      # else
      #   puts ">>>>>>>>>> FETCHED on #{tag} <<<<<<<<<"
      # end

      nodes = []
      
      results.each do |r|
        if r[:media_type] == "person"
          node = OpenStruct.new
          node.media_type = r[:media_type]
          node.id = r[:id]
          node.name = r[:name]
          node.poster = r[:profile_path]
          nodes << node

          r[:known_for].each do |m|
            node = OpenStruct.new
            node.media_type = m[:media_type]
            node.id = m[:id]
            node.name = m[:title] || m[:original_name]
            node.poster = m[:poster_path]
            nodes << node
          end
        else

          node = OpenStruct.new
          node.media_type = r[:media_type]
          node.id = r[:id]
          node.name = r[:title] || r[:original_name]
          node.poster = r[:poster_path]
          nodes << node
        end
      end

      return nodes
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
          TmdbService.person_credits(person_id)
          people << TmdbService.person_details(person_id)
        end
      end.flatten(2)

      movie_ids.map do |movie_id|
        if Movie.exists?(movie_id)
          movies << Movie.find(movie_id)
        else
          TmdbService.movie_credits(movie_id)
          movies << TmdbService.movie_details(movie_id)
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
