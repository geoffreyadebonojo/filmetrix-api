class Matcher
  attr_reader :credit_lists
  
  def initialize(credit_lists)
    @credit_lists = credit_lists
  end

  def matches
    credit_lists.flatten(2)
         .group_by{|x|x[:id]}.to_a
         .filter{|y|y[1].count>1}.to_h
  end
end