require "ostruct"

module Types
  class QueryType < Types::BaseObject
    field :nodes, [Types::D3::NodeType], null: true do
      argument :ids, [String]
      argument :count, Integer
    end

    field :links, [Types::D3::LinkType], null: true do
      argument :ids, [String]
      argument :count, Integer
    end
    
    field :search, [Types::D3::NodeType], null: true do
      argument :term, String
    end

    field :details, Types::D3::DetailType, null: true do
      argument :id, String
    end

    def details(args)
      TmdbService.details(args[:id])
    end
    
    def search(args)
      results = TmdbService.search(args[:term])[:results]
      nodes = []
      
      results.each do |r|
        if r[:media_type] == "person"
          node = OpenStruct.new
          node.media_type = r[:media_type]
          node.id = [r[:media_type],r[:id]].join("-")
          node.name = r[:name]
          node.poster = r[:profile_path]
          nodes << node

          r[:known_for].each do |m|
            node = OpenStruct.new
            node.media_type = m[:media_type]
            node.id =[m[:media_type],m[:id]].join("-")
            node.name = m[:title] || m[:original_name]
            node.poster = m[:poster_path]
            nodes << node
          end
        else

          node = OpenStruct.new
          node.media_type = r[:media_type]
          node.id = [r[:media_type],r[:id]].join("-")
          node.name = r[:title] || r[:original_name]
          node.poster = r[:poster_path]
          nodes << node
        end
      end

      return nodes
    end

    def links(args)
      return assembler(args)[:links]
    end
    
    def nodes(args)
      return assembler(args)[:nodes]
    end

    private

    def assembler(args)
      ids = args[:ids]
      count = args[:count]

      links = []
      nodes = []

      ids.each do |id|
        x = TmdbService.credits(id)
        nodes << x[:nodes].first(count+1)
        links << x[:links].first(count)
      end


      binding.pry

      # movie_creds = movie_ids.each do |mids|
      #   x = TmdbService.movie_credits(mids)
      #   nodes << x[:nodes].first(count+1)
      #   links << x[:links].first(count)
      # end

      # person_creds = person_ids.each do |pids|
      #   x = TmdbService.person_credits(pids)
      #   nodes << x[:nodes].first(count+1)
      #   links << x[:links].first(count)
      # end
      
      # might not be the best way to manade the +1 links to nodes issue

      {
        nodes: nodes.flatten.uniq,
        links: links.flatten.uniq
      }
    end
  end
end
