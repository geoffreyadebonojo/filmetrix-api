class TmdbService
	def self.person_credits(id)
		url = root + "/person/" + id.to_s + "/combined_credits" + "?" + key

		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
		
		movies = []
		tv = []

		body[:cast].each do |credit|
			movies << credit if credit[:media_type] == "movie"
			tv << credit if credit[:media_type] == "tv"
		end

		body[:crew].each do |credit|
			movies << credit if credit[:media_type] == "movie"
			tv << credit if credit[:media_type] == "tv"
		end

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
				link = {
					person_id: id,
					movie_id: m[0],
					roles: c
				}
				Link.create!(link)
			end
		end
	end

	def self.movie_details(id)
		url = root + "/movie/" + id.to_s + "?" + key
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
		
		body["source"] = "details"

		# write_to_file("movie-#{id.to_s}-details", body)
	end
	
	def self.person_details(id)
		url = root + "/person/" + id.to_s + "?" + key
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys

		body["source"] = "details"

		# write_to_file("person-#{id.to_s}-details", body)
	end
	
	def self.search(term)
		url = root + "/search/multi?" + key + query(term)
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
		self.build_from_results(body)
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
 
