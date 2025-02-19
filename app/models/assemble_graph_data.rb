class AssembleGraphData
  def self.execute(ids)
    @ids = ids
    @credit_list = []
    @response = []

    all = @ids.map do |id|
      details = check_detail_cache(id)
      credits = check_credit_cache(id)
      @credit_list << credits

      { anchor: details,
        credits: credits }
    end

    count = 100

    # TODO: refactor for efficiency
    all.each do |entity|
      @response << Assembler::Builder.new(entity).assembled_response(@credit_list, count)
    end

    return @response
  end

  def self.check_credit_cache(id)
    begin 
      Rails.cache.fetch("#{id}--credits") do
        TmdbService.credits(id).grouped_credits
      end
    rescue
      TmdbService.credits(id).grouped_credits
    end
  end

  def self.check_detail_cache(id)
    begin 
      Rails.cache.fetch("#{id}--detail") do
        TmdbService.details(id).data
      end
    rescue
      TmdbService.details(id).data
    end
  end
end
