class CreditCacheManager
  attr_reader :formatted_lists

  def initialize(ids)
    credit_lists = CreditList.where(id: ids).map(&:grouped_credits)
    @formatted_lists = OrderedList.new(credit_lists).format
  end

  def return_cache_list_for_actor(id)

  end

  def filter_genres
    remove_genres = [99, 10402]

    filtered_lists = formatted_lists.map do |list|
      list.select! do |item|
        (item[:genre_ids] & remove_genres).empty?
      end
    end

    return filtered_lists
  end
end