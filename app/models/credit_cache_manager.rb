class CreditCacheManager
  attr_reader :ids, :credits_hash, :forbidden_genres

  def initialize(ids, forbidden_genres)
    @ids = ids
    @forbidden_genres = forbidden_genres
    credit_lists = CreditList.where(id: ids).map(&:grouped_credits)
    ordered_lists = OrderedList.new(credit_lists).format
    
    list_hash = {}

    x = ids.each_with_index do |id, i|
      list_hash[id] = ordered_lists[i]
    end

    @credits_hash = list_hash
    
  end

  def return_cache_list_for_actor(actor_id, count)
    filtered_credits[actor_id].first(count)
  end

  def filtered_credits
    new_hash = {}

    ids.each do |id| 
      filtered = credits_hash[id].reject do |item|
        (item[:genre_ids] & forbidden_genres).present?
      end
      new_hash[id] = filtered
    end

    new_hash
  end
end