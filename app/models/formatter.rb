class Formatter
  attr_reader :credit_lists, :matching_ids

  def initialize(credit_lists)
    @credit_lists = credit_lists
    @matching_ids = Matcher.new(credit_lists).matches.keys
  end
  
  def format
    ordered_lists = credit_lists.map do |list|
      matches = []
      credits = []
      list.each do |item|
        if matching_ids.include?(item[:id])
          matches << item
        else
          credits << item
        end
      end
      matches + credits
    end
  end
end