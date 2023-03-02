class CreditManager
  attr_reader :all

  def initialize(credit_hashes)
    @all = credit_hashes
  end

  def pluck(*keys)
    if (all.first.keys && keys).empty?
      raise "can't find key #{keys} on the credit hash"
    else
      all.map{|x|x.slice(*keys)}
    end
  end

  def find_by(*args)
    if [:id, :name].exclude?(args.first)
      raise "only accepts :id, :name"
    else
      all.find{|x| x[args.first]==args.last}
    end
  end

  # sort_by(:order, :desc)
  def sort_by(*args)
    if [:popularity, :order].exclude?(args.first)
      raise "only accepts first arg :popularity, :order"
    else
      actors = includes_department("Acting")
      if args.last == :asc
        actors.sort_by { |k| k[args.first] }.reverse
      elsif args.last == :desc
        actors.sort_by { |k| k[args.first] }
      else
        raise "only accepts second arg :asc, :desc"
      end
    end
  end

  def by_type(media_type)
    if ["person", "movie", "tv"].include?(media_type)
      all.filter{|x|x[:media_type]==media_type}
    else
      raise 'must be "person", "movie", or "tv"'
    end
  end

  def includes_role(role)
    all.filter{|x|x[:roles].map{|x|x.downcase}.include?(role.downcase)}
  end
  
  def includes_department(dept)
    all.filter{|x|x[:departments].map{|x|x.downcase}.include?(dept.downcase)}
  end
end