class MatchMaker
  attr_accessor :nodes, :matches, :copy

  def initialize(nodes)
    @nodes = nodes
    @copy = nodes
    @matches = []
    check_for_matches
  end


  private

  def check_for_matches
    @matches = nodes.map do |n|
      a = n.shift

      x = []

      nodes.each do |m|
        next if n == m

        (m & n).each do |z|
          n.unshift(n.delete(z))
        end
        
        x << n
      end

      x.unshift(a)

      x.flatten
    end
  end
end

# actors.sort_by { |k| k[args.first] }.reverse
#
