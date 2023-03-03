class TmdbService		
	def self.search(term)
		url = root + "/search/multi?" + key + query(term)

		existing = Search.where('term LIKE ?', "%#{term.upcase.gsub(" ", "%")}%")

		return existing.first.data if existing.present?

		response = Faraday.get url

		search = Search.create!({
			term: term,
			body: JSON.parse(response.body)
		})

		return search.data
	end

	def self.person_details(id)
		url = root + "/person/" + id + "?" + key
		
		tag = "details-person-#{id}"
		api_hit = false

		details = Rails.cache.fetch(tag) do
			api_hit = true
			response = Faraday.get url
			body = JSON.parse(response.body).deep_symbolize_keys
			body[:media_type] = "person"
			return body
		end

		if api_hit
			puts ">>>>>>>>>> API HIT on #{tag} <<<<<<<<<"
		else
			puts ">>>>>>>>>> FETCHED on #{tag} <<<<<<<<<"
		end

		return details
	end


	def self.movie_details(id)
		url = root + "/movie/" + id.to_s + "?" + key

		tag = "details-movie-#{id}"
		api_hit = false

		details = Rails.cache.fetch(tag) do
			api_hit = true
			response = Faraday.get url
			body = JSON.parse(response.body).deep_symbolize_keys
			body[:media_type] = "movie"
			return body
		end

		if api_hit
			puts ">>>>>>>>>> API HIT on #{tag} <<<<<<<<<"
		else
			puts ">>>>>>>>>> FETCHED on #{tag} <<<<<<<<<"
		end

		return details	
	end

	def self.movie_credits(id)
		url = root + "/movie/" + id.to_s + "/credits" + "?" + key

		tag = "credits-movie-#{id}"
		api_hit = false

		results = Rails.cache.fetch(tag) do
			api_hit = true
			response = Faraday.get url
			body = JSON.parse(response.body).deep_symbolize_keys

			movie = self.movie_details(id)

			movie_anchor = {
				id: movie[:id],
				name: movie[:title] || movie[:name],
				popularity: movie[:popularity],
				order: nil,
				media_type: movie[:media_type],
				roles: [],
				departments: [],
				full_id: "#{movie[:media_type]}-#{movie[:id]}",
				poster: movie[:poster_path]
			}

			creds = [ 
				body[:cast],
				body[:crew]
		  ].flatten.group_by{|x|x[:id]}.to_a.map do |pe|
				GeneratePersonFromMovieCredits.new(pe).node
			end

			[ movie_anchor, creds ]
		end

		credits = CreditManager.new(*results).data

		if api_hit
			puts ">>>>>>>>>> API HIT on #{tag} <<<<<<<<<"
		else
			puts ">>>>>>>>>> FETCHED on #{tag} <<<<<<<<<"
		end

		return credits
	end

	def self.person_credits(id)
		url = root + "/person/" + id.to_s + "/credits" + "?" + key

		tag = "person-movie-#{id}"
		api_hit = false

		results = Rails.cache.fetch(tag) do
			api_hit = true
			response = Faraday.get url
			body = JSON.parse(response.body).deep_symbolize_keys

			person = self.person_details(id)

			person_anchor = {
				id: person[:id],
				name: person[:name],
				popularity: person[:popularity],
				order: nil,
				media_type: 'person',
				roles: [],
				departments: [],
				full_id: "person-#{person[:id]}",
				poster: person[:profile_path]
			}

			creds = [ 
				body[:cast],
				body[:crew]
		  ].flatten.group_by{|x|x[:id]}.to_a.map do |mov|
				GenerateMovieFromPersonCredits.new(mov).node
			end

			[ person_anchor, creds ]
		end

		credits = CreditManager.new(*results).data

		if api_hit
			puts ">>>>>>>>>> API HIT on #{tag} <<<<<<<<<"
		else
			puts ">>>>>>>>>> FETCHED on #{tag} <<<<<<<<<"
		end

		return credits
	end

	private

	GenerateMovieFromPersonCredits = Struct.new(:entry) do
		def node
			group = entry[1]

			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}

			movie = group.first

			movie.merge!(
				name: movie[:title] || movie[:name],
				media_type: "movie",
				roles: r,
				departments: d,
				id: "movie-#{movie[:id]}",
				poster: movie[:poster_path]
			)

			movie
		end
	end


	GeneratePersonFromMovieCredits = Struct.new(:entry) do
		def node
			group = entry[1]

			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}

			person = group.first.slice(
				:name,
				:popularity,
				:order
			)

			person.merge!(
				media_type: "person",
				roles: r,
				departments: d,
				id: "person-#{group.first[:id]}",
				poster: group.first[:profile_path]
			)

			person
		end
	end
	
	def self.query(term)
		cleaned = term.downcase
		"&language=en-US&query=#{cleaned}&page=1&include_adult=false"
	end

	def self.root
		"https://api.themoviedb.org/3"
	end

	def self.key
		"api_key=a45442ace7db89ca6533dfeb22961976"
	end
end
 
