class Assembler::Filter
  attr_reader :credits
  attr_reader :counts
  attr_reader :media_type

  def initialize(credits, media_type)
    @credits = credits
    @media_type = media_type
    @counts={directing: 2, production: 3, writing: 2, acting: 23}
  end

  def apply(*depts)
    filtered = credits.filter do |x|
      (depts & x[:departments]).any?
    end
    return filtered
  end

  def list_departments
    credits.map{|d|d[:departments]}.flatten.uniq
  end

  def gather(args=nil)
    if media_type == "tv"
      gather_tv_credits

    elsif media_type == "movie"
      options = args || counts
      gather_movie_credits(options)

    else
      raise ArgumentError
    end
  end

  def gather_tv_credits
    credits.reject do |credit|
      credit[:poster].nil? || credit[:poster].empty?
    end
    # .sort_by {|k| k[:popularity]} # already sorted by order
  end

  def gather_movie_credits(options)
    valid_departments = options.all? do |k,v| 
      list_departments.include?(k.to_s.capitalize)
    end

    raise ArgumentError unless valid_departments 

    categories = Hash.new()
    gathered_list = []

    options.map do |k,v|
      categories[k] = []
    end

    options.each do |opt|
      dept_name = opt[0]

      credits.each do |credit|
        next if credit[:poster].nil? || credit[:poster].empty?

        if credit[:departments].include?(dept_name.to_s.capitalize)
          categories[dept_name] << credit
        end
      end

      gathered_list << categories[dept_name].sort_by {|k| k[:popularity]}.reverse.first(options[dept_name])
    end

    gathered_list.flatten.uniq
  end
end