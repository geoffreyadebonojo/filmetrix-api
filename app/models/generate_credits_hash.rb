class GenerateCreditsHash
  attr_reader :ids, :credits_hash, :forbidden_genres

  def initialize(ids, forbidden_genres=nil)
    @ids = ids
    @forbidden_genres = forbidden_genres || [99, 10402]

    credit_lists = CreditList.where(id: ids).map(&:grouped_credits)
    ordered_lists = OrderedList.new(credit_lists).format
    
    list_hash = {}

    x = ids.each_with_index do |id, i|
      list_hash[id] = ordered_lists[i]
    end

    @credits_hash = list_hash
  end

  def limit_count(args)
    filtered_credits_hash[args[:actor_id]].first(args[:count])
  end
  
  def filtered_credits_hash
    new_hash = {}
    ids.each do |id| 
      new_hash[id] = credits_hash[id].reject do |item|
        (item[:genre_ids] & forbidden_genres).present?
      end
    end
    new_hash
  end
end