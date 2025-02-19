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

    field :saveGraph, Types::D3::ResponseType, null: true do
      argument :ids, String
      argument :lockedNodes, String
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
      ids = args[:ids].split(",")
      return AssembleGraphData.execute(ids)
    end

    def findBySlug(args)
      result = SavedGraph.find_by(slug: args[:slug])

      return result if result.present? 
      return []
    end

    def saveGraph(args)
      positions = args[:lockedNodes].split(";").map{|n|n.split(",")}
      entries = args[:ids].split(";").map{|n| n.split(",")}      

      saved_graph = find_or_create(entries, positions)

      return {
        resource_id: saved_graph.id,
        share_url: saved_graph.filmetrix_link
      }      
    end

    private

    def find_or_create(entries, position)
      # address this later
      saved_graph = SavedGraph.find_by(existing: entries)
      return saved_graph if saved_graph.present?

      ids = entries.map{|n| n.first}

      SavedGraph.create(
        slug: SecureRandom.uuid.split('-').first,
        request_ids: ids,
        body: AssembleGraphData.execute(ids),
        existing: entries,
        position: position
      )
    end
  end
end
