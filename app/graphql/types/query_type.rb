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
      argument :count, Integer
    end

    field :saveGraph, Types::D3::ResponseType, null: true do
      argument :ids, String
      argument :count, String
    end

    field :findBySlug, Types::D3::SlugGraphType, null: true do
      argument :slug, String
    end

    field :getNextPage, [Types::D3::NodeType], null: true do
      argument :term, String
    end

    field :discover, [Types::D3::NodeType], null: true do
      argument :terms, String
    end

    #####################################################

    def discover(args)
      discovered = TmdbService.discover(args[:terms])
      return discovered
    end

    def getNextPage(args) 
      results = TmdbService.get_next_page(args[:term])

      return [] if results.nil?
      return [] if results.empty?

      Assembler::SearchResult.new(results).nodes
    end

    def search(args)
      api_results = TmdbService.search(args[:term])

      return [] if api_results.nil?
      return [] if api_results.empty?
      
      search_results = api_results.fetch(:results)

      Assembler::SearchResult.new(search_results).nodes
    end

    def details(args)
      TmdbService.details(args[:id]).data
    end
    
    def graphData(args)
      return AssembleGraphData.execute(args)
    end

    def saveGraph(args)
      saved_graph = find_or_create(args)

      return {
        resource_id: saved_graph.id,
        share_url: saved_graph.filmetrix_link
      }      
    end

    def find_or_create(args)
      anchors_list = args[:ids].split(",").zip(args[:count].split(","))      
      
      saved_graph = SavedGraph.find_by(existing: anchors_list)
      return saved_graph if saved_graph.present?

      SavedGraph.create(
        slug: SecureRandom.uuid.split('-').first,
        request_ids: args[:ids],
        body: assemble_graph_data_from_saved(args),
        existing: anchors_list
      )
    end
    
    def findBySlug(args)
      result = SavedGraph.find_by(slug: args[:slug])
      return result if result.present? 
      return []
    end

    private

    def assemble_graph_data_from_saved(args)
      response = AssembleGraphData.execute(args)
      anchors_list = args[:ids].split(",").zip(args[:count].split(","))
      saved_graph = SavedGraph.find_by(existing: anchors_list)

      return saved_graph if saved_graph.present?

      response
    end
  end
end
