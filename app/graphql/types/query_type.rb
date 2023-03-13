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
    
    field :graphEntity, Types::D3::GraphEntityType, null: true do
      argument :ids, [String]
    end

    field :graphData, [Types::D3::GraphEntityType], null: true do
      argument :ids, String
    end

    def graphData(args)
      data = assembler(args)

      return data
    end

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
      cl =   []
      resp = []
      # resp = {}

      all = args[:ids].split(",").map do |id|
        gl = Rails.cache.fetch("credits--#{id}") {
          TmdbService.credits(id).grouped_credits
        }
        cl << gl

        an = Rails.cache.fetch("details--#{id}") {
          TmdbService.details(id)
        }

        {
          anchor: an,
          credits: gl
        }
      end

      @matcher_found_matches = Matcher.new(cl).found_matches
  

      all.each do |z|
        anchor_id = z[:anchor].id
        anchor =    z[:anchor].data
        inner_list = []
        inner_links = []
        inner_nodes = []
        matches_for_anchor = []
        other = []

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

        inner_nodes << anchor_node

        if anchor[:media_type] == "person"
          z[:credits].each do |y|
            if y[:genre_ids].exclude?(10402) && y[:genre_ids].exclude?(99) && y[:genre_ids].present?
              if @matcher_found_matches.include?(y[:id])
                matches_for_anchor << y
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

        inner_list += matches_for_anchor
        inner_list += other

        inner_list.each do |w|
          if anchor[:media_type] == "person"
            inner_links << { 
              source: anchor_id, 
              target: w[:id], 
               roles: w[:roles]
            }
          else
            inner_links << { 
              source: w[:id], 
              target: anchor_id, 
               roles: w[:roles]
            }
          end
        end

        inner_nodes << inner_list.map do |li|
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
        end.flatten
        
        resp << {
          id: anchor_id,
          nodes: inner_nodes.flatten.first(20),
          links: inner_links.flatten.first(20)
        }

        # resp[anchor_id] = {
        #   nodes: inner_nodes.flatten.first(20),
        #   links: inner_links.flatten.first(20)
        # }
      end

      resp
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
