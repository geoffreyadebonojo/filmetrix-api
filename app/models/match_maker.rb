class MatchMaker
  attr_accessor :nodes, :matches

  def initialize(nodes)
    @nodes = nodes
    @matches = []

    check_for_matches
  end

  def check_for_matches
    nodes.each do |n|
      top = nodes.pop
      nodes.each do |m|
        @matches << (top & m)
      end
    end
  end
end