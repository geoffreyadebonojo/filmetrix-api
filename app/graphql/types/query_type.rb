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
      Result.new(results).nodes
    end

    def details(args)
      TmdbService.details(args[:id]).data
    end

    def graphData(args)
      return assembler(args)
    end

    private

    def assembler(args)
      credit_list =   []
      resp = []
      # resp = {}

      all = args[:ids].split(",").map do |id|
        credits = check_credit_cache(id)
        credit_list << credits
        details = check_detail_cache(id)
        { anchor: details,
          credits: credits }
      end

      matches = Matcher.new(credit_list).found_matches
  
      all.each do |z|
        anchor_id = z[:anchor].id
        anchor = z[:anchor].data
        assembler = Assembler.new(z)

        inner_list = []
        inner_links = []
        inner_nodes = []
        # matches_for_anchor = []
        # other = []

        inner_nodes << assembler.define_anchor

        assembler.assemble_credits(matches)
        inner_list = assembler.filtered
        
        
        assembler.assemble_inner_links
        inner_links = assembler.inner_links

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

    def check_credit_cache(id)
      begin 
        Rails.cache.fetch("credits--#{id}") do
          TmdbService.credits(id).grouped_credits
        end
      rescue
        TmdbService.credits(id).grouped_credits
      end
    end

    def check_detail_cache(id)
      begin 
        Rails.cache.fetch("details--#{id}") do
          TmdbService.details(id)
        end
      rescue
        TmdbService.details(id)
      end
    end
  end
end
