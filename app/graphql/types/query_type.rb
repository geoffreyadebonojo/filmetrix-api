module Types
  class QueryType < Types::BaseObject
    field :search, [Types::D3::NodeType], null: true do
      argument :key, String
      argument :term, String
    end
    
    field :details, Types::D3::DetailType, null: true do
      argument :key, String
      argument :id, String
    end
    
    field :graphData, [Types::D3::GraphEntityType], null: true do
      argument :key, String
      argument :ids, String
    end

    field :saveGraph, Types::D3::ResponseType, null: true do
      argument :ids, String
      argument :counts, [Integer]
      argument :key, String
    end

    field :findBySlug, Types::D3::SlugGraph, null: true do
      argument :slug, String
    end

    def search(args)
      return [] unless accepted_key(args[:key])
      results = TmdbService.search(args[:term])[:results]
      return [] if results.empty?
      Assembler::Result.new(results).nodes
    end

    def details(args)
      return [] unless accepted_key(args[:key])
      TmdbService.details(args[:id]).data
    end

    def graphData(args)
      return [] unless accepted_key(args[:key])
      response = assemble_graph_data(args)
      return response
    end
    
    def saveGraph(args)
      anchorsList = args[:ids].split(",").zip(args[:counts])
      savedGraph = SavedGraph.find_by(request_ids: args[:ids])
      
      if savedGraph.present?
        response = {
          status: 403,
          msg: "resource already exists",
          resource_id: savedGraph.id,
          resource_slug: savedGraph.slug
        }
      else
        assembled_data = assemble_graph_data(args)
        uuid = SecureRandom.uuid.split('-').first

        sg = SavedGraph.new(
          slug: uuid,
          request_ids: args[:ids],
          body: assembled_data,
          existing: anchorsList
        )

        if sg.save!
          response = {
            status: 201,
            msg: "saved",
            resource_id: savedGraph.id,
            resource_slug: savedGraph.slug
          }
        else
          response = {
            status: 403,
            msg: "couldn't save",
            resource_id: '',
            resource_slug: ''
            # include error msg
          }
        end
      end

      return response
    end
    
    def findBySlug(args)
      result = SavedGraph.find_by(slug: args[:slug])

      if result.present?
        # create?... no that wouldn't work. Slugs are for sharing lol.
        return result
      end
      return []
    end

    private

    def accepted_key(key)
      Rails.env.production? ? key === "6GzCesnexrzgnDv3FfxbHBrb" : true
    end

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
        assembler = Assembler::Builder.new(entity)
        assembler.assemble_credits( Assembler::Matcher.new(credit_list).found_matches )
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

    # def update_graph_store(id, list)
    #   existing = Rails.cache.fetch(id) {[]}
    #   if existing.map{|x|x[:id]}.sort != list.map{|y|y[:id]}.sort
    #     Rails.cache.write(id, list)
    #   end
    # end
  end
end
