class CreditList < ApplicationRecord
	
	has_one :movie

	def write
		File.write("db/seeds/#{id}/credit-list.json", data.to_json)
	end

	# should be the default?

	def constructor
    if self.id.include?("person")
      constructor = GenerateMovieFromPersonCredits
    elsif self.id.include?("movie")
      constructor = GeneratePersonFromMovieCredits
    elsif self.id.include?("tv")
			constructor = GeneratePersonFromTvCredits
    else
      raise "the id is fucked up?"
    end
	end

  def grouped_credits
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

	def crew_by_department
		crew.group_by{|x|x[:department]}
	end

	def jobs_within_department(dept)
		crew_by_department[dept].group_by{|x|x[:job]}
	end

	def directors
		group = jobs_within_department("Directing")

		return [
			group["Director"], 
			group["Executive Director"]
		].flatten.compact.uniq
	end

	def producers
		group = jobs_within_department("Production")
		
		return [
			group["Producer"], 
			group["Executive Producer"]
		].flatten.compact.uniq
	end

	def top_results
		list = [
			cast_by_order.first(5),
			directors.first(3),
			producers.first(2)
		].flatten(3)

		list.group_by{|x|x[:id]}.to_a.map do |ent|
			constructor.new(ent).node
		end
	end

	# might include some unexpected results
	def cast_by_popularity(min=nil, max=nil)
		pops = cast.map{|x|x[:popularity]}
		min = min || pops.min
		max = max || pops.max

		cast.filter do |x|
			min <= x[:popularity] && x[:popularity] <= max
		end.sort_by { |k| k[:popularity] }.reverse
	end

	def crew_by_popularity(min=nil, max=nil)
		pops = crew.map{|x|x[:popularity]}
		min = min || pops.min
		max = max || pops.max

		crew.filter do |x|
			min <= x[:popularity] && x[:popularity] <= max
		end.sort_by { |k| k[:popularity] }.reverse
	end

	def cast_by_order
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

	GeneratePersonFromTvCredits = Struct.new(:entry) do
		def node
			group = entry[1]

			r = group.map{ |x|
				roles = x[:job] || x[:character]
			}.reject{|y|y.empty?}.uniq

			d = group.map{ |x|
				departments = x[:department] 
			}.reject{|y|y.nil?}.uniq

			person = group.first.slice(
				:name,
				:popularity,
				:order
			)
			person.merge!(
				media_type: "person",
				roles: r,
				departments: [],
				id: "person-#{group.first[:id]}",
				poster: group.first[:profile_path]
			)
			person
		end
	end
end
