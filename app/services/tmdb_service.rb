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

		movies.each do |credit|
			roles = credit[:job] || credit[:character]

			Link.create!({
				person_id: id,
				movie_id: credit[:id],
				roles: roles
			})
		end

		binding.pry

	end

	def self.movie_details(id)
		url = root + "/movie/" + id.to_s + "?" + key
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
		binding.pry
	end

	def self.person_details(id)
		url = root + "/person/" + id.to_s + "?" + key
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
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
 
