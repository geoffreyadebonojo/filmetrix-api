class CreditList < ApplicationRecord

	# should be the default?
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

	def combined_credits
    [cast, crew].flatten
  end

	def cast
		self.data[:cast]
	end

	def crew
		self.data[:crew]
	end

	def existing_departments
		grouped_credits.map{|x|x[:departments]}.flatten.uniq
	end

	def by_department
		crew.group_by{|x|x[:department]}
	end

	# might include some unexpected results
	def sort_by_popularity(min=nil, max=nil)
		pops = grouped_credits.map{|x|x[:popularity]}
		min = min || pops.min
		max = max || pops.max

		grouped_credits.filter do |x|
			min <= x[:popularity] && x[:popularity] <= max
		end.sort_by { |k| k[:popularity] }.reverse
	end

	def sort_by_order
		cast.sort_by { |k| k[:order] }
	end

	private 

  GenerateMovieFromPersonCredits = Struct.new(:entry) do
		def node
			group = entry[1]
			
			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}.uniq
			
			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}.uniq
			
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
			}.reject{|y|y.empty?}.uniq

			d = group.map{ |x|
				departments = x[:department] || "Acting"
			}.reject{|y|y.empty?}.uniq

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
