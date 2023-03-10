class Matcher
  attr_reader :actor_ids, :overlaps
  def initialize(actor_ids)
    @actor_ids = actor_ids
  end

  def overlapping_entities
    lists = CreditList.where(id: actor_ids).map do |x|
      x.grouped_credits#.map{|y|y[:id]}
    end


    lists.flatten(2)
         .group_by{|x|x[:id]}.to_a
         .filter{|y|y[1].count>1}.to_h
  end
end