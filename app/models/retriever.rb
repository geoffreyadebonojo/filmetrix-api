class Retriever
  def self.retrieve_data(id, type)
    raise ArgumentError if [:details, :credits].exclude?(type)
    raise ArgumentError if id.to_s === 0

    # first, check in cache
    cached_result = Rails.cache.read("#{id}--#{type.to_s}")
    return cached_result if cached_result.present?

    existing = find_in_db(id, type)

    if existing.present?
      Rails.cache.write("#{id}--#{type.to_s}", existing.data)
      return existing
    else
      result = query_tmdb(id, type)
      Rails.cache.write("#{id}--#{type.to_s}", result.data)
      return result
    end

    # Rails.cache.fetch("#{id}--#{type.to_s}") do
    #   # if not in cache, check in db
    #   existing = find_in_db(id, type)
    #   # if found in db, write to cache
    #   if existing.present?
    #     puts "---------------"
    #     puts "--found in db--"
    #     puts "---------------"
    #     existing
    #   end
    #   # if not found in db, query TMDB
    #   query_tmdb(id, type)
    #   # write to cache
    # end
  end

  private
  
  def self.query_tmdb(id, type)
    return TmdbService.details(id)                 if type == :details
    return TmdbService.credits(id).grouped_credits if type == :credits
  end

  def self.find_in_db(id, type)
    return Detail.find_by(id: id)     if type == :details
    return CreditList.find_by(id: id).grouped_credits if type == :credits 
  end
end