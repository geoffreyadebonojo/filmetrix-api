class TmdbService		

	def self.discover(args)
		# base = "https://api.themoviedb.org/3/discover/movie?"
		# certs = "certification=R&certification_country=US"
		# params = "&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate&"
		# url = base+certs+params+key

		url = "https://api.themoviedb.org/3/movie/74/similar?api_key=a45442ace7db89ca6533dfeb22961976&language=en-US&page=1"

		response = Faraday.get url
		body = JSON.parse(response.body)
		return [] if body["total_results"] == 0
	end


	def self.search(term)
		existing = Search.where('term LIKE ?', "%#{term.upcase.gsub(" ", "%")}%")

		if existing.present?
			results = existing.map{|x|
				x.data[:results]
			}.flatten
			
			return {results: results}
		end

		url = root + "/search/multi?" + key + query(term, 1)
		response = Faraday.get url
		body = JSON.parse(response.body)
		return [] if body["total_results"] == 0

		search = Search.create(
			term: term,
			body: body
		)

		return search.data
	end

	def self.get_next_page(term)
		# must always exist
		latest_search = Search.where('term LIKE ?', "%#{term.upcase.gsub(" ", "%")}%")

		existing = latest_search.max{|x| x.data[:page]}
		# where page is highest
		current_number = existing.data[:page]
		total_pages =    existing.data[:total_pages]
		
		return if latest_search.map{|x| x.data[:page]}.include?(current_number+1)
		return if current_number >= total_pages
		
		url_for_next_page = root + "/search/multi?" + key + query(existing.term, current_number+1)
		response = Faraday.get url_for_next_page
		next_page_body = JSON.parse(response.body)

		return [] if next_page_body["total_results"] == 0

		new_search = Search.create(
			term: term,
			body: next_page_body
		)

		return new_search.data[:results]
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
			
			details = Detail.create(
				id: id,
				body: body
			)

			return details
		end
	end

	def self.credits(id)
		entity, id_number = id.split("-")
		if %w(person movie tv).exclude?(entity) 
			raise "#{entity} not an accepted entity type"
		else
			existing = CreditList.find_by(id: id)
			return existing if existing.present?
			
			url = root + "/#{entity}" + "/#{id_number.to_s}" + "/credits" + "?" + key
			response = Faraday.get url
			body = JSON.parse(response.body)

			credits_list = CreditList.create({
				id: id,
				body: body
			})

			return credits_list
		end
	end

	private
	
	def self.query(term, page_number=1)
		cleaned = term.downcase
		"&language=en-US&query=#{cleaned}&page=#{page_number}&include_adult=false"
	end

	def self.root
		"https://api.themoviedb.org/3"
	end

	def self.key
		"api_key=#{ENV.fetch("TMDB_API_KEY")}"
	end
end
 
