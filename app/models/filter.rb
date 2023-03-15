class Filter
  attr_reader :movie_credits

  def initialize(movie_credits)
    @movie_credits = movie_credits
  end

  def apply(*depts)
    filtered = movie_credits.filter do |x|
      (depts & x[:departments]).any?
    end
    return filtered
  end

  def gather
    directors = []
    producers = []
    actors =    []

    movie_credits.map do |x|
      next if x[:poster].nil? || x[:poster].empty?
      if x[:departments].include?("Directing")
        directors << x
      elsif x[:departments].include?("Production")
        producers << x
      elsif x[:departments].include?("Acting")
        actors << x
      end
    end

    directors.sort_by { |k| k[:popularity] }.reverse.first(2) +
    producers.sort_by { |k| k[:popularity] }.reverse.first(2) + 
    actors.sort_by { |k| k[:order] }.first(26)
  end
end