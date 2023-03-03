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
			credits_list =  if existing.present?
												existing
											else
												CreditList.create!({
													id: id,
													body: body
												})
											end

			return CreditManager.new(
				self.details(id).anchor_data, 
				credits_list.grouped_credits
			).data
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
		"api_key=a45442ace7db89ca6533dfeb22961976"
	end
end
 
