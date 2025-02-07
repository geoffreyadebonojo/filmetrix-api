class TmdbService		

	def self.search(term)
		if Rails.env.development?
			existing = Search.where('term LIKE ?', "%#{term.upcase.gsub(" ", "%")}%")
			return {results: existing.map{|x|x.data[:results]}.flatten} if existing.present?
		end

		url = root + "/search/multi?" + key + query(term, 1) #1 page
		response = Faraday.get url
		body = JSON.parse(response.body)
		return [] if body["total_results"] == 0

		if Rails.env.development?
			search = Search.create(
				term: term,
				body: body
			)
		end

		return search.data
	end

	def self.details(id)
		entity, id_number = id.split("-")
		check_entity_type(entity)
		check_id_is_number(id_number)

		existing = Detail.find_by(id: id)
		return existing if existing.present?
		
		result = fetch_from_Tmdb(id, :details)
		Detail.create(result)
	end

	def self.credits(id)
		entity, id_number = id.split("-")
		check_entity_type(entity)
		check_id_is_number(id_number)

		existing = CreditList.find_by(id: id)
		return existing if existing.present?
	
		result = fetch_from_Tmdb(id, :credits)
		CreditList.create(result)
	end

	def self.discover(args)
		# base = "https://api.themoviedb.org/3/discover/movie?"
		# certs = "certification=R&certification_country=US"
		# params = "&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate&"
		# url = base+certs+params+key

		url = root + "/discover/movie?" + key + "&with_people=" + args
		response = Faraday.get url
		body = JSON.parse(response.body)

		return [] if body["total_results"] == 0
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
	
	private

	def self.fetch_from_Tmdb(id, type)
		entity, id_number = id.split("-")

		credit_param = type == :credits ? "/credits" : ""
		
		url = "#{root}/#{entity}/#{id_number.to_s}#{credit_param}?#{key}"
		response = Faraday.get url
		
		puts "======================================="
		puts "==>> #{type.to_s.upcase} FETCHED FROM TMDB API <<=="
		puts "======================================="

		body = JSON.parse(response.body)
		body["media_type"] = entity
		
		return {
			id: id,
			body: body
		}
	end
	
	def self.check_entity_type(entity)
		raise ArgumentError if %w(person movie tv).exclude?(entity)
	end

	def self.check_id_is_number(id_number)
		raise ArgumentError if id_number.to_s === 0
	end

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
 
