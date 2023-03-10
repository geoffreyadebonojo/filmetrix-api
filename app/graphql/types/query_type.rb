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
      argument :ids, [String]
    end

    # field :graphData, Types::D3::GraphDataType, null: true do
    #   argument :ids, [String]
    #   argument :count, Integer
    # end

    def querySingle(args)
      ids = args[:ids]
      data = assembler(args)
      # Rails.cache.fetch("query-single-#{ids.first}") do

      return {
        nodes: data[:nodes],
        links: data[:links]
      }
    end

    # def graphData(args)
    #   assembler(args)
    # end

    def details(args)
      TmdbService.details(args[:id]).data
    end

    def credits(args)
      TmdbService.credits(args[:id]).grouped_credits
    end

    def search(args)
      results = TmdbService.search(args[:term])[:results]

      return [] if results.empty?

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
      # count = args[:count]
      # until I can figure out how to fix FE
      ids = args[:ids].first.split(",")

      links = []
      
      all = ids.map do |id|
        {
          anchor: TmdbService.details(id),
          credits: TmdbService.credits(id).grouped_credits
        }
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
          poster: anchor[:profile_path] || anchor[:poster_path],
          entity: anchor[:media_type]
        }
        
        if anchor[:media_type] == "person"
          anchor_node[:type] = [anchor[:known_for_department].downcase]
        else
          anchor_node[:type] = anchor[:genres].map{|x|genre_name(x[:id])}
        end

        nodes << anchor_node
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
        inner_list += other

        inner_list.each do |w|
          if anchor[:media_type] == "person"
            links << { 
              source: anchor_id, 
              target: w[:id], 
              roles: w[:roles]
            }
          else
            links << { 
              source: w[:id], 
              target: anchor_id, 
              roles: w[:roles]
            }
          end
        end

        nodes << inner_list.map do |li|
          obj = {
            id: li[:id],
            name: li[:name],
            poster: li[:poster],
            type: li[:type]
          }

          if li[:media_type] == "person"
            obj[:type] = li[:departments].map{|x|x.gsub('\u0026', "&").downcase}
          else
            obj[:type] = li[:genre_ids].map{|x|genre_name(x)}
          end

          obj[:entity] = li[:media_type]

          obj
        end
      end

      {
        nodes: nodes.flatten.uniq,
        links: links.flatten.uniq
      }
    end

    def genre_name(code)
      vals = {
        28=> 'action',
        12=> 'adventure',
        16=> 'animation',
        35=> 'comedy',
        80=> 'crime',
        99=> 'documentary',
        18=> 'drama',
        10751=> 'family',
        14=> 'fantasy',
        36=> 'history',
        27=> 'horror',
        10402=> 'music',
        9648=> 'mystery',
        10749=> 'romance',
        878=> 'scifi',
        10770=> 'tvmovie',
        53=> 'thriller',
        10752=> 'war',
        37=> 'western'
      }

      vals[code]
    end
  end
end
