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
      assemble_graph_data(args)
    end

    private

    def assemble_graph_data(args)
      credit_list = []
      response = []

      all= args[:ids].split(",").map do |id|
        credits = check_credit_cache(id)
        credit_list << credits
        details = check_detail_cache(id)
        { anchor: details,
          credits: credits }
      end

      all.each do |entity|
        assembler = Assembler.new(entity)
        assembler.assemble_credits( Matcher.new(credit_list).found_matches )
        assembler.assemble_inner_links
        assembler.assemble_inner_nodes
        response << assembler.assembled_response
      end

      response
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
