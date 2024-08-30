class AssembleGraphData

  def self.execute(args)
    credit_list = []
    response = []

    all= args[:ids].split(",").map do |id|
      credits = check_credit_cache(id)
      credit_list << credits
      details = check_detail_cache(id)
      { 
        anchor: details,
        credits: credits
      }
    end

    all.each do |entity|
      assembler = Assembler::Builder.new(entity)
      assembler.assemble_credits(credit_list)
      assembler.assemble_inner_links
      assembler.assemble_inner_nodes
      response << assembler.assembled_response
    end

    response
  end

  private 

  def self.check_credit_cache(id)
    begin 
      Rails.cache.fetch("#{id}--credits") do
        TmdbService.credits(id).grouped_credits
      end
    rescue
      puts "============================="
      puts "=>> FETCHED FROM TMDB API <<="
      puts "============================="

      TmdbService.credits(id).grouped_credits
    end
  end

  def self.check_detail_cache(id)
    begin 
      Rails.cache.fetch("#{id}--detail") do
        TmdbService.details(id)
      end
    rescue
      puts "============================="
      puts "=>> FETCHED FROM TMDB API <<="
      puts "============================="

      TmdbService.details(id)
    end
  end
end
