class SingleEntityGraphData
  attr_reader :anchor_id, :credits, :data

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

  def initialize(anchor_id, credits)
    @anchor_id = anchor_id
    @credits = credits
    @data = { nodes: nodes,
              links: links }
  end



  def anchor_node
    anchor = Detail.find(anchor_id).data

    entity = anchor_id.split("-")[0]
    type =  if entity == "person"
              anchor[:known_for_department].downcase
            else
              anchor[:genres].map{|v|v[:name].downcase}
            end

    { id: anchor_id,
      name: anchor[:name],
      poster: anchor[:profile_path],
      type: [type],
      entity: entity }
  end

  def nodes
    # still missing anchor
    collected = credits.map do |credit|
      { id: credit[:id],
        name: credit[:name],
        poster: credit[:poster],
        #only for movie
        type: credit[:genre_ids].map{|gid|GENRE_NAME[gid]},
        entity: credit[:media_type] }
    end
    collected.unshift(anchor_node)
    collected
  end

  def links
    credits.map do |credit|
      { source: anchor_id,
        target: credit[:id],
        roles: credit[:roles] }
    end
  end
end