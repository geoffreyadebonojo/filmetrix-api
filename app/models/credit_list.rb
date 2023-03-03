class CreditList < ApplicationRecord

  def combined_credits
    [self.data[:cast], self.data[:crew]].flatten
  end

  def grouped_credits
    if self.id.include?("person")
      constructor = GenerateMovieFromPersonCredits
    elsif self.id.include?("movie")
      constructor = GeneratePersonFromMovieCredits
    elsif self.id.include?("tv")
      raise "not set up yet"
    else
      raise "the id is fucked up?"
    end

    self.combined_credits.group_by{|x|x[:id]}.to_a.map do |ent|
      constructor.new(ent).node
    end
  end

  GenerateMovieFromPersonCredits = Struct.new(:entry) do
		def node
			group = entry[1]

			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}

			movie = group.first

			movie.merge!(
				name: movie[:title] || movie[:name],
				media_type: "movie",
				roles: r,
				departments: d,
				id: "movie-#{movie[:id]}",
				poster: movie[:poster_path]
			)

			movie
		end
	end

	GeneratePersonFromMovieCredits = Struct.new(:entry) do
		def node
			group = entry[1]

			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}

			person = group.first.slice(
				:name,
				:popularity,
				:order
			)

			person.merge!(
				media_type: "person",
				roles: r,
				departments: d,
				id: "person-#{group.first[:id]}",
				poster: group.first[:profile_path]
			)

			person
		end
	end
end
