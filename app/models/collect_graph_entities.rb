class CollectGraphEntities
  attr_reader :ids, :data, :count

  def initialize(ids, count)
    @ids = ids
    @count = count
    @data = collect_data
  end

  def collect_data
    @links = []
    @nodes = []
    @result = []

    credit_lists = ids.map do |id|
      CreditList.find(id).grouped_credits
    end

    entry = {}

    ids.zip(OrderedLists.new(credit_lists).format).each do |list|
      id = list[0]

      credits = list[1].filter do |item|
        (item.fetch(:genre_ids, []) & [10402, 99]).empty?
      end.first(count)

      details = Detail.find(id)
      anchor = anchor_node(id, details.data)

      collected = collect_nodes(id, credits)
      collected.unshift(anchor)
      
      l = credits.map do |credit|
        { 
          source: list[0],
          target: credit[:id],
          roles:  credit[:roles] }
      end

      entry[id] = {
        nodes: collected.first(count+1),
        links: l.first(count)
      }
    end

    entry
  end

  def collect_nodes(id, grouped_credits)
    anchor_entity = id.split("-")[0]
    grouped_credits.map do |credit|
    { id:     credit[:id],
      name:   credit[:name],
      poster: credit[:poster],
      type:   handle_node_type(credit, anchor_entity),
      entity: credit[:media_type] }
    end
  end

  def handle_node_type(credit, anchor_entity)
    case anchor_entity
    when "person"
      credit[:genre_ids].map{|gid|GENRE_NAME[gid]}
    when "movie"
      credit[:departments].map{|d| d.downcase}
    when "tv"
    end
  end

  def anchor_node(id, details)
    poster = details[:profile_path] || details[:poster_path]
    name = details[:name] || details[:title]
    anchor_entity = id.split("-")[0]

    { id:     id,
      name:   name,
      poster: poster,
      type:   [handle_anchor_type(anchor_entity, details)],
      entity: anchor_entity }
  end

  def handle_anchor_type(anchor_entity, details)
    case anchor_entity
    when "person"
      details[:known_for_department].downcase
    when "movie"
      details[:genres].map{|v|v[:name].downcase}
    when "tv"
      details[:genres].map{|v|v[:name].downcase}
    end
  end

  GENRE_NAME = {
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
end