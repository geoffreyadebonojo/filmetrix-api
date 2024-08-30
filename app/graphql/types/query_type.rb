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
      argument :counts, String
      # argument :key, String
    end

    field :findBySlug, Types::D3::SlugGraph, null: true do
      argument :slug, String
    end

    field :fetchMovieList, [[String]], null: true do
      argument :user_id, String
    end

    field :fetchGraphList, [Types::D3::SavedGraphType], null: true do
      argument :user_id, String
    end

    field :addToMovieList, [[String]], null: true do
      argument :user_id, String
      argument :movie_id, String
    end

    field :removeFromMovieList, [[String]], null: true do
      argument :user_id, String
      argument :movie_id, String
    end


    field :getNextPage, [Types::D3::NodeType], null: true do
      argument :term, String
    end

    # create a UserType to package up graphs and movielists

    field :discover, [Types::D3::NodeType], null: true do
      argument :terms, String
    end

    field :fetchFriendList, [Types::D3::FriendType], null: true do
      argument :user_id, String
    end


    #####################################################

    def
       fetchFriendList(args)
      user = User.find(args[:user_id])
      return user.users
    end

    def discover(args)
      discovered = TmdbService.discover(args[:terms])
      return discovered
    end

    def getNextPage(args) 
      results = TmdbService.get_next_page(args[:term])

      return [] if results.nil?
      return [] if results.empty?
      Assembler::Result.new(results).nodes
    end

    def details(args)
      return [] unless accepted_key(args[:key])
      TmdbService.details(args[:id]).data
    end

    def graphData(args)
      return AssembleGraphData.execute(args)
    end
    
    def saveGraph(args)
      anchorsList = args[:ids].split(",").zip(args[:counts].split(","))      
      savedGraph = SavedGraph.find_by(existing: anchorsList)
      
      if savedGraph.present?
        response = {
          status: 403,
          msg: "resource already exists",
          resource_id: savedGraph.id,
          share_url: savedGraph.filmetrix_link
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
            resource_id: sg.id,
            share_url: sg.filmetrix_link
          }
        else
          # If somebody tries to save an already existing graph,
          # create a usergraph for them
          response = {
            status: 403,
            msg: "couldn't save",
            resource_id: '',
            share_url: ''
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

    private
        
    def find_or_create(args)
      anchors_list = args[:ids].split(",").zip(args[:counts].split(","))      

      saved_graph = SavedGraph.find_by(existing: anchors_list)
      return saved_graph if saved_graph.present?

      SavedGraph.create(
        slug: SecureRandom.uuid.split('-').first,
        request_ids: args[:ids],
        body: assemble_graph_data(args),
        existing: anchors_list
      )
    end

  end
end
