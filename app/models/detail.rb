class Detail < ApplicationRecord
  def anchor_data
    return movie_anchor_data if  self.data[:media_type] == "movie"
    return person_anchor_data if self.data[:media_type] == "person"
  end
  
  private

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
