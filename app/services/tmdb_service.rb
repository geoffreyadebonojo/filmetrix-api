class TmdbService

		
	def self.search(term)
		url = root + "/search/multi?" + key + query(term)
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
	
		return body[:results]
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
	

	GeneratePersonFromMovieCredits = Struct.new(:pe) do
		def node
			group = pe[1]

			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}

			person = group.first.slice(
				:id,
				:name,
				:popularity,
				:profile_path,
				:order
			)

			person.merge!(
				media_type: "person",
				roles: r,
				departments: d
			)
			
			person
		end
	end



	def self.movie_credits(id)
		url = root + "/movie/" + id.to_s + "/credits" + "?" + key

		tag = "credits-movie-#{id}"
		api_hit = false

		results = Rails.cache.fetch(tag) do
			api_hit = true
			response = Faraday.get url
			body = JSON.parse(response.body).deep_symbolize_keys

			[ body[:cast],
				body[:crew]
		  ].flatten.group_by{|x|x[:id]}.to_a.map do |pe|
				GeneratePersonFromMovieCredits.new(pe).node
			end
		end

		credits = CreditManager.new(results)
		binding.pry
		# if Link.where(person_id: pe[0]).where(movie_id: id).empty?
		# 	Link.create!({
		# 		person_id: pe[0],
		# 		movie_id: id,
		# 		roles: c,
		# 		department: d,
		# 		order: person[:order] || nil
		# 	})
		# end

		if api_hit
			puts ">>>>>>>>>> API HIT on #{tag} <<<<<<<<<"
		else
			puts ">>>>>>>>>> FETCHED on #{tag} <<<<<<<<<"
		end

		return credits	
	end













	# def self.__movie_credits(id)
	# 	url = root + "/movie/" + id.to_s + "/credits" + "?" + key

	# 	response = Faraday.get url
	# 	body = JSON.parse(response.body).deep_symbolize_keys

	# 	people = []

	# 	[body[:cast],body[:crew]].flatten.group_by{|x|x[:id]}.to_a.each do |pe|
	# 		group = pe[1]

	# 		c = group.map{ |x|
	# 			roles = x[:job] || x[:character]
	# 		}.reject{|y|y.empty?}

	# 		d = group.map{ |x|
	# 			departments = x[:department] || "Acting"
	# 		}.reject{|y|y.empty?}

	# 		person = group.first

	# 		unless Person.exists?(pe[0])
	# 			person["source"] = "credits"
	# 			person["media_type"] = "person"

	# 			people <<	person.except(
	# 				:gender,
	# 				:cast_id,
	# 				:character,
	# 				:job,
	# 				:department,
	# 				:credit_id,
	# 				:order
	# 			)
	# 		end
			
	# 		if Link.where(person_id: pe[0]).where(movie_id: id).empty?
	# 			Link.create!({
	# 				person_id: pe[0],
	# 				movie_id: id,
	# 				roles: c,
	# 				department: d,
	# 				order: person[:order] || nil
	# 			})
	# 		end
	# 	end
		
	# 	generate_person_credits(people, id)
	# 	# write_to_file("movie-#{id.to_s}-credits", people)
	# 	Person.insert_all!(people)
	# end
	
	# def self.__person_credits(id)
	# 	url = root + "/person/" + id.to_s + "/combined_credits" + "?" + key

	# 	response = Faraday.get url
	# 	body = JSON.parse(response.body).deep_symbolize_keys
		
	# 	movies = []
	# 	tv = []

	# 	body[:cast].each do |credit|
	# 		movies << credit if credit[:media_type] == "movie"
	# 		tv << credit if credit[:media_type] == "tv"
	# 	end

	# 	body[:crew].each do |credit|
	# 		movies << credit if credit[:media_type] == "movie"
	# 		tv << credit if credit[:media_type] == "tv"
	# 	end

	# 	generate_movie_credits(movies, id)
		
	# 	write_to_file("person-#{id.to_s}-credits", movies)
	# end

	def self.generate_movie_credits(movies, id)
		movies.group_by{|x|x[:id]}.to_a.each do |m|
			group = m[1]

			c = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			movie = group.first

			unless Movie.exists?(m[0])
				movie["source"] = "credits"
				Movie.create!(
					movie.except(
						:job,
						:character, 
						:credit_id, 
						:order, 
						:department
					)
				)
			end

			if Link.where(person_id: id).where(movie_id: m[0]).empty?
				Link.create!({
					person_id: id,
					movie_id: m[0],
					roles: c,
					order: movie[:order] #credit, actually
				})
			end
		end
	end

	def self.build_from_results(body)
		results = body[:results]

		people = []
		movies = []
		tv =     []

		# body[:source] = "search"

		results.each do |r|
			if r[:media_type] == "person"
				people << r.except(
					:known_for
				)

				r[:known_for].each do |m|
					movies << m if m[:media_type] == "movie"
					tv << m     if m[:media_type] == "tv"
				end
			end

			movies << r if r[:media_type] == "movie"
			tv << r     if r[:media_type] == "tv"
		end

		Movie.insert_all!(movies)
		Person.insert_all!(people)
	end

	def self.write_to_file(full_id, body)
		File.write("db/#{full_id}.json", body.to_json)
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
 
