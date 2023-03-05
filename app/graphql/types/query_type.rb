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
    
    field :querySingle, Types::D3::QuerySingleType, null: true do
      argument :id, String
    end

    def querySingle(args)
      id = args[:id]

      Rails.cache.fetch("query-single-#{id}") do
        {
          anchor: details(args),
          credits: credits(args)
        }
      end
    end

    def details(args)
      TmdbService.details(args[:id]).data
    end

    def credits(args)
      TmdbService.credits(args[:id]).grouped_credits
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
      @data ||= assembler(args)
      return @data[:links]
    end
    
    def nodes(args)
      @data ||= assembler(args)
      return @data[:nodes]
    end

    private

    def assembler(args)

      # ids = args[:ids]
      count = args[:count]
      # until I can figure out how to fix FE
      ids = args[:ids].first.split(",")

      links = []
      
      all = ids.map do |id|
        Rails.cache.fetch("query-single-#{id}") do 
          {
            anchor: TmdbService.details(id),
            credits: TmdbService.credits(id).grouped_credits
          }
        end
      end

      c = all.map{|e|e[:credits]}.flatten
             .map{|x|x[:id]}
             .group_by{|i|i}.to_a
             .filter{|x|x[1].count>1}
             .map{|d|d[0]}

      overlaps = []
      nodes = []
      links = []

      all.each do |z|
        anchor_id = z[:anchor].id
        anchor = z[:anchor].data
        
        inner_list = []

        anchor_node = { 
          id: anchor_id, 
          name: anchor[:name] || anchor[:title], 
          poster: anchor[:profile_path] || anchor[:poster_path]
        }

        inner_list << anchor_node

        matches = []
        other = []

        if anchor[:media_type] == "person"
          z[:credits].each.map do |y|
            if y[:genre_ids].exclude?(10402) && y[:genre_ids].exclude?(99) && y[:genre_ids].present?
              if c.include?(y[:id])
                matches << y
              else
                other << y
              end
            end
          end
        else
          z[:credits].each.map do |y|
            other << y
          end
        end

        inner_list += matches
        inner_list += other.first(count)

        inner_list[1..-1].each do |w|
          # if anchor[:media_type] == "person"
            links << { 
              source: anchor_id, 
              target: w[:id], 
              roles: w[:roles]
            }
          # else
          #   links << { 
          #     source: w[:id], 
          #     target: anchor_id, 
          #     roles: w[:roles]
          #   }
          # end
        end

        nodes << inner_list.map do |li|
          {
            id: li[:id],
            name: li[:name],
            poster: li[:poster]
          }
        end
      end

      {
        nodes: nodes.flatten.uniq,
        links: links.flatten.uniq
      }
    end
  end
end
