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
      argument :user_id, String
    end

    field :findBySlug, Types::D3::SlugGraphType, null: true do
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

    def getNextPage(args) 
      results = TmdbService.get_next_page(args[:term])
      return [] if results.empty?
      Assembler::Result.new(results).nodes    
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
      saved_graph = find_or_create(args)
      user = User.find_by(id: args[:user_id])

      if user.present? && !user.saved_graphs.pluck(:slug).include?(saved_graph.slug)
        user.saved_graphs << saved_graph
      end

      return {
        resource_id: saved_graph.id,
        share_url: saved_graph.filmetrix_link
      }      
    end
    
    def findBySlug(args)
      result = SavedGraph.find_by(slug: args[:slug])
      return result if result.present? 
      return []
    end

    def fetchGraphList(args)
      graphs_lists = User.find(args[:user_id]).saved_graphs
      gathered_ids = graphs_lists.map do |g|
        {
          slug: g.slug,
          list: g.data.map{|x|x[:id]}
        }
      end

      graph_list_posters = gathered_ids.map do |graph_list_hash|
        posters = graph_list_hash[:list].map do |id|
          profile = Detail.find(id).data.fetch(:profile_path, nil)
          poster = Detail.find(id).data.fetch(:poster_path, nil)
          img = profile || poster
          'https://image.tmdb.org/t/p/w185_and_h278_bestv2' + img
        end

        {
          slug: graph_list_hash[:slug],
          posters: posters
        }
      end

      return graph_list_posters
    end

    def fetchMovieList(args)
      movie_list = User.find(args[:user_id]).movies.pluck(:_id, :title, :poster)
      return movie_list
    end

    def addToMovieList(args)
      user = User.find(args[:user_id])
      movie = Movie.find_by(_id: args[:movie_id])

      if movie.nil?
        detail = Detail.find(args[:movie_id])
        credit_list = CreditList.find(args[:movie_id])
        
        if detail.present?
          new_movie = Movie.create!({
            _id: args[:movie_id],
            title: detail.data[:title],
            poster: detail.data[:poster_path]
          })

          new_movie.detail = detail
          new_movie.credit_list = credit_list

          user.movies << new_movie
        else
          raise "--> Hey, something's up; couldn't find existing Detail?"
        end
      elsif movie.present?
        if user.movies.find_by(_id: args[:movie_id]).nil?
          user.movies << movie
        end
      end

      return user.movies.pluck(:_id, :title, :poster)
    end

    def removeFromMovieList(args)
      user = User.find(args[:user_id])
      movie = Movie.find_by(_id: args[:movie_id])

      user_movie = UserMovie.where(user: user).where(movie: movie)

      puts "UserMovie not found?? How???" if user_movie.empty?
      
      user_movie.destroy_all
      return user.movies.pluck(:_id, :title, :poster)
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
        { 
          anchor: details,
          credits: credits
        }
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
        Rails.cache.fetch("#{id}--credits") do
          TmdbService.credits(id).grouped_credits
        end
      rescue
        puts "============================="
        puts "=>> FETCHED FROM IMDB API <<="
        puts "============================="

        TmdbService.credits(id).grouped_credits
      end
    end

    def check_detail_cache(id)
      begin 
        Rails.cache.fetch("#{id}--detail") do
          TmdbService.details(id)
        end
      rescue
        TmdbService.details(id)
      end
    end

    # def check_saved_graphs(user_id) 
    #   begin 
    #     Rails.cache.fetch("saved_graphs--#{user_id}") do
          
    #     end
    #   rescue

    #   end
    # end

        
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
