class Assembler::SearchResult
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

    # maybe order items by popularity? Or optional filter?
    items
  end

  def media_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id = [item[:media_type], item[:id]].join("-")
    node.type = item[:genre_ids].map{|x|genre_name(x)}.compact
    node.name = item[:title] || item[:original_name]
    node.poster = item[:poster_path]
    node.year = item[:release_date].split("-")[0] if !item[:release_date].nil?
    node.year = item[:first_air_date].split("-")[0] if !item[:first_air_date].nil?
    node.score = {
      popularity: item[:popularity],
      vote_average: item[:vote_average],
      vote_count: item[:vote_count]
    }
    node.known_for_department = []
    node
  end
  
  def person_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id = [item[:media_type],item[:id]].join("-")
    node.type = []
    node.name = item[:name]
    node.poster = item[:profile_path]
    node.year = ''
    node.score = {
      popularity: item[:popularity]
    }
    node.known_for_department = item[:known_for_department]
    node
  end

  def genre_name(code)
    vals = {
      28=> 'action',
      12=> 'adventure',
      16=> 'animation',
      35=> 'comedy',
      80=> 'crime',
      99=> 'documentary',
      18=> 'drama',
      10751=> 'family',
      14=> 'fantasy',
      36=> 'history',
      27=> 'horror',
      10402=> 'music',
      9648=> 'mystery',
      10749=> 'romance',
      878=> 'scifi',
      10770=> 'tvmovie',
      53=> 'thriller',
      10752=> 'war',
      37=> 'western'
    }
    vals[code]
  end
end