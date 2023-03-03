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

	def self.details(id)
		entity, id_number = id.split("-")

		if %w(person movie tv).exclude?(entity)
			raise "can't search for entity='#{entity}'" 
		elsif id_number.to_s === 0
			raise "can't search for id_number='#{id_number}: must be integer'" 
		else

			existing = Detail.find_by(id: id)
			return existing if existing.present?

			url = root + "/#{entity}" + "/#{id_number.to_s}" + "?" + key
			response = Faraday.get url
			body = JSON.parse(response.body)
			body["media_type"] = entity

			details = Detail.create!({
				id: id,
				body: body
			})

			return details
		end
	end

	def self.credits(id)
		entity, id_number = id.split("-")
		if %w(person movie tv).exclude?(entity) 
			raise "#{entity} not an accepted entity type"
		else

			# use CreditList.where to just scoop them all at once?
			url = root + "/#{entity}" + "/#{id_number.to_s}" + "/credits" + "?" + key

			response = Faraday.get url
			body = JSON.parse(response.body)
			
			existing = CreditList.find_by(id: id)
	
			if existing.present?
				credits_list = existing
			else
				credits_list = CreditList.create!({
					id: id,
					body: body
				})
			end

			if entity == "person"
				anchor = self.details(id).person_anchor_data

			elsif entity == "movie"
				anchor = self.details(id).movie_anchor_data

			elsif entity == "tv"
			else
				raise "something went wrong?"
			end

			creds = credits_list.grouped_credits

			return CreditManager.new(anchor, creds).data
		end
	end
	
	# def self.movie_credits(id)
	# 	entity, id_number = id.split("-")
	# 	url = root + "/#{entity}" + "/#{id_number.to_s}" + "/credits" + "?" + key

	# 	response = Faraday.get url
	# 	body = JSON.parse(response.body)
		
	# 	existing = CreditList.find_by(id: id)

	# 	if existing.present?
	# 		credits_list = existing
	# 	else
	# 		credits_list = CreditList.create!({
	# 			id: id,
	# 			body: body
	# 		})
	# 	end

	# 	# this process needs to move
	# 	movie_anchor = self.details(id).movie_anchor_data
	# 	creds = credits_list.combined_credits.group_by{|x|x[:id]}.to_a.map do |pe|
	# 		GeneratePersonFromMovieCredits.new(pe).node
	# 	end

	# 	return CreditManager.new(movie_anchor, creds).data
	# end

	# def self.person_credits(id)
	# 	entity, id_number = id.split("-")
	# 	url = root + "/#{entity}" + "/#{id_number.to_s}" + "/credits" + "?" + key

	# 	response = Faraday.get url
	# 	body = JSON.parse(response.body)
		
	# 	existing = CreditList.find_by(id: id)

	# 	if existing.present?
	# 		credits_list = existing
	# 	else
	# 		credits_list = CreditList.create!({
	# 			id: id,
	# 			body: body
	# 		})
	# 	end

	# 	person_anchor = self.details(id).person_anchor_data

	# 	creds = credits_list.grouped_credits

	# 	return CreditManager.new(person_anchor, creds).data
	# end

	private

	# GenerateMovieFromPersonCredits = Struct.new(:entry) do
	# 	def node
	# 		group = entry[1]

	# 		r = group.map{ |x|
	# 			roles = x[:job] || x[:character]
	# 		}.reject{|y|y.empty?}

	# 		d = group.map{ |x|
	# 			departments = x[:department] || "Acting"
	# 		}.reject{|y|y.empty?}

	# 		movie = group.first

	# 		movie.merge!(
	# 			name: movie[:title] || movie[:name],
	# 			media_type: "movie",
	# 			roles: r,
	# 			departments: d,
	# 			id: "movie-#{movie[:id]}",
	# 			poster: movie[:poster_path]
	# 		)

	# 		movie
	# 	end
	# end


	# GeneratePersonFromMovieCredits = Struct.new(:entry) do
	# 	def node
	# 		group = entry[1]

	# 		r = group.map{ |x|
	# 			roles = x[:job] || x[:character]
	# 		}.reject{|y|y.empty?}

	# 		d = group.map{ |x|
	# 			departments = x[:department] || "Acting"
	# 		}.reject{|y|y.empty?}

	# 		person = group.first.slice(
	# 			:name,
	# 			:popularity,
	# 			:order
	# 		)

	# 		person.merge!(
	# 			media_type: "person",
	# 			roles: r,
	# 			departments: d,
	# 			id: "person-#{group.first[:id]}",
	# 			poster: group.first[:profile_path]
	# 		)

	# 		person
	# 	end
	# end
	
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
 
