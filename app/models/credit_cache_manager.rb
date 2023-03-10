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

  def ordered_credits(args)
    limited_set = limit_count(args[:actor_id], args[:count])
    limited_set.sort_by{|k|k[args[:order_by]]}.reverse
  end

  def limit_count(actor_id, count)
    filtered_credits_hash[actor_id].first(count)
  end

  def filtered_credits_hash
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