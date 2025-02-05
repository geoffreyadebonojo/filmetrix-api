class AssembleGraphData
  # NODE SENDCOUNT
  def self.execute(args)
    @credit_list = []
    @response = []
    
    if args[:count].is_a?(Integer)
      count = args[:count]
    else
      count = args[:count].split(",").map(&:to_i).sum
    end

    all = args[:ids].split(",").map do |id|
      credits = check_credit_cache(id)
      @credit_list << credits

      details = check_detail_cache(id)
      
      { anchor: details,
        credits: credits }
    end

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
        TmdbService.details(id)
      end
    rescue
      TmdbService.details(id)
    end
  end
end
