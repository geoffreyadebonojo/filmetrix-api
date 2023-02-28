class TmdbService

	def self.movie_credits(id)
		url = root + "/movie/" + id.to_s + "/credits" + "?" + key

		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys

		people = []

		[body[:cast],body[:crew]].flatten.group_by{|x|x[:id]}.to_a.each do |pe|
			group = pe[1]

			c = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}

			person = group.first

			unless Person.exists?(pe[0])
				person["source"] = "credits"
				person["media_type"] = "person"

				people <<	person.except(
					:gender,
					:cast_id,
					:character,
					:job,
					:department,
					:credit_id,
					:order
				)
			end
			
			if Link.where(person_id: pe[0]).where(movie_id: id).empty?
				Link.create!({
					person_id: pe[0],
					movie_id: id,
					roles: c,
					department: d,
					order: person[:order] || nil
				})
			end
		end
		
		generate_person_credits(people, id)
		# write_to_file("movie-#{id.to_s}-credits", people)
		Person.insert_all!(people)
	end

	def generate_person_credits(people, id)
	end
	
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

		generate_movie_credits(movies, id)
		
		write_to_file("person-#{id.to_s}-credits", movies)
	end

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

	def self.movie_details(id)
		url = root + "/movie/" + id.to_s + "?" + key
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys
		
		body["source"] = "details"
		body["media_type"] = "movie"

		# write_to_file("movie-#{id.to_s}-details", body)
	end
	
	def self.person_details(id)
		url = root + "/person/" + id.to_s + "?" + key
		response = Faraday.get url
		body = JSON.parse(response.body).deep_symbolize_keys

		body["source"] = "details"
		body["media_type"] = "person"

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
 
