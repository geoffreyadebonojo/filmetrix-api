module Types
  class QueryType < Types::BaseObject
    field :search, [Types::D3::NodeType], null: true do
      argument :term, String
    end

    field :details, Types::D3::DetailType, null: true do
      argument :id, String
    end

    field :graphData, [Types::D3::GraphEntityType], null: true do
      argument :ids, String
    end

    def search(args)
      results = TmdbService.search(args[:term])[:results]

      return [] if results.empty?
      nodes = []
      
      results.each do |r|
        if r[:media_type] == "person"
          nodes << Result.person_entity(r)

          r[:known_for].each do |m|
            nodes << Result.media_entity(m)
          end
        else

          nodes << Result.media_entity(r)
        end
      end

      return nodes
    end

    def details(args)
      TmdbService.details(args[:id]).data
    end

    def graphData(args)
      return assembler(args)
    end

    private

    def assembler(args)
      cl =   []
      resp = []
      # resp = {}

      all = args[:ids].split(",").map do |id|
        # gl = Rails.cache.fetch("credits--#{id}") {
          gl = TmdbService.credits(id).grouped_credits
        # }
        cl << gl

        # an = Rails.cache.fetch("details--#{id}") {
          an = TmdbService.details(id)
        # }
        
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

        if anchor[:media_type] != "person"
          # inner_list = Filter.new(inner_list).apply("Directing")
          inner_list = Filter.new(inner_list).gather
        end

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
          nodes: inner_nodes.flatten.first(30),
          links: inner_links.flatten.first(30)
        }
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
