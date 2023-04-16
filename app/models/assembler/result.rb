class Assembler::Result
  attr_reader :nodes, :results

  def initialize(results)
    @results = results
    @nodes = collect
  end

  private

  def collect
    items = []
    results.each do |r|
      if r[:media_type] == "person"
        # binding.pry
        items << person_entity(r)
        r[:known_for].each do |m|
          items << media_entity(m)
        end
      else
        items << media_entity(r)
      end
    end
    items
  end

  def media_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id =[item[:media_type],item[:id]].join("-")
    node.name = item[:title] || item[:original_name]
    node.poster = item[:poster_path]
    node.year = item[:release_date].split("-")[0] if !item[:release_date].nil?
    node.year = item[:first_air_date].split("-")[0] if !item[:first_air_date].nil?
    # node.score = {
    #   popularity: item[:popularity],
    #   vote_average: item[:vote_average],
    #   vote_count: item[:vote_count]
    # }
    node.known_for_department = []
    node
  end
  
  def person_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id = [item[:media_type],item[:id]].join("-")
    node.name = item[:name]
    node.poster = item[:profile_path]
    node.year = ''
    # node.score = {
    #   popularity: item[:popularity]
    # }
    node.known_for_department = item[:known_for_department]
    node
  end
end