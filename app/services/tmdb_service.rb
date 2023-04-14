class TmdbService		
	def self.search(term)
		existing = Search.where('term LIKE ?', "%#{term.upcase.gsub(" ", "%")}%")
		return existing.first.data if existing.present?
		
		url = root + "/search/multi?" + key + query(term)
		response = Faraday.get url
		body = JSON.parse(response.body)
		return [] if body["total_results"] == 0

		search = Search.create!(
			term: term,
			body: body
		)

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
	
	def self.query(term)
		cleaned = term.downcase
		"&language=en-US&query=#{cleaned}&page=1&include_adult=false"
	end

	def self.root
		"https://api.themoviedb.org/3"
	end

	def self.key
		"api_key=#{ENV.fetch("TMDB_API_KEY")}"
	end
end
 
