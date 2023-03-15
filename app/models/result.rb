class Result
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
    node
  end

  def person_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id = [item[:media_type],item[:id]].join("-")
    node.name = item[:name]
    node.poster = item[:profile_path]
    node
  end
end