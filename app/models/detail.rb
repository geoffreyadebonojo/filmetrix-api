class Detail < ApplicationRecord
  has_one :movie

	def write
		File.write("db/seeds/#{id}/details.json", data.to_json)
	end
  
  def anchor_data
    return movie_anchor_data if  self.data[:media_type] == "movie"
    return person_anchor_data if self.data[:media_type] == "person"
    return tv_anchor_data if     self.data[:media_type] == "tv"
  end
  
  private

  def tv_anchor_data
    tv = self.data
    {
			id: tv[:id],
			name: tv[:title],
			popularity: tv[:popularity],
			order: nil,
			media_type: "tv",
			roles: [],
			departments: [],
			full_id: "tv-#{tv[:id]}",
			poster: tv[:poster_path]
		}
  end

  def movie_anchor_data
    movie = self.data
    {
			id: movie[:id],
			name: movie[:title],
			popularity: movie[:popularity],
			order: nil,
			media_type: "movie",
			roles: [],
			departments: [],
			full_id: "movie-#{movie[:id]}",
			poster: movie[:poster_path]
		}
  end

  def person_anchor_data
    person = self.data
    {
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
  end
end
