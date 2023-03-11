class Matcher
  attr_accessor :grouped_credits

  def initialize(grouped_credits)
    @grouped_credits = grouped_credits
  end

  def found_matches
    grouped_credits.flatten(2)
                .group_by{|x|x[:id]}.to_a
                .filter{|y|y[1].count>1}.to_h.keys
  end
end