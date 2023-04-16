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
    end

    field :findBySlug, Types::D3::SlugGraph, null: true do
      argument :slug, String
    end

    field :fetchMovieList, [[String]], null: true do
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
  end
end
