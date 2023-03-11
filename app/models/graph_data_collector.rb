class GraphDataCollector
  def self.collect(args)
    credits_manager = GenerateCreditsHash.new(args[:actor_ids])

    all = credits_manager.filtered_credits_hash

    collected_data = all.map do |id, credits|
      limited = credits.first(args[:count])
      SingleEntityGraphData.new( id, 
                                 limited ).data
    end.flatten

    links = []
    nodes = []

    collected_data.each do |packet|
      links << packet[:links]
      nodes << packet[:nodes]
    end

    { links: links.flatten.uniq,
      nodes: nodes.flatten.uniq }
  end
end