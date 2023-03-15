class Result
  def self.media_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id =[item[:media_type],item[:id]].join("-")
    node.name = item[:title] || item[:original_name]
    node.poster = item[:poster_path]
    node
  end

  def self.person_entity(item)
    node = OpenStruct.new
    node.media_type = item[:media_type]
    node.id = [item[:media_type],item[:id]].join("-")
    node.name = item[:name]
    node.poster = item[:profile_path]
    node
  end
end