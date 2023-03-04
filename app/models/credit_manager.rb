class CreditManager
  attr_reader :anchor, :all

  def initialize(anchor, credit_hashes)
    @anchor = anchor
    @all = credit_hashes
  end

  def data
    nodes = []

    set = pluck(:id, :name, :poster, :popularity, :genre_ids)

    set.pop
    
    nodes << set.reject{
      |x| x[:genre_ids].include?(10402) || x[:genre_ids].include?(99)
    }.sort_by { |x| x[:popularity] }.reverse
    
    nodes.unshift({
      id: anchor[:full_id],
      name: anchor[:name],
      poster: anchor[:poster]
    })

    {
      nodes: nodes.flatten,
      links: links.flatten
    }
  end

  def links
    pluck(:id, :media_type, :roles).map do |c|
      if c[:media_type] == 'person'
        {
          source: c[:id],
          target: anchor[:full_id],
          roles: c[:roles]
        }
      else
        {
          source: anchor[:full_id],
          target: c[:id],
          roles: c[:roles]
        }
      end
    end
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
      raise "only accepts :id, :name, :full_id"
    else
      all.find{|x| x[args.first]==args.last}
    end
  end
  
  def sort_by(*args)
    # sort_by(:order, :desc)
    if [:popularity, :order].exclude?(args.first)
      raise "only accepts first arg :popularity, :order"
    else
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

  def actors
    all.filter{|x|x[:departments].map{|x|x.downcase}.include?("acting")}
  end
  
  def includes_department(dept)
    all.filter{|x|x[:departments].map{|x|x.downcase}.include?(dept)}
  end
end


# GENRES = {
#   "28": "action",
#   "12": "adventure",
#   "16": "animation",
#   "35": "comedy",
#   "80": "crime",
#   "99": "documentary",
#   "18": "drama",
#   "10751": "family",
#   "14": "fantasy",
#   "36": "history"
#   "27": "horror",
#   "10402": "music"
#   "9648": "mystery",
#   "10749": "romance",
#   "878": "scifi",
#   "10770": "tvmovie",
#   "53": "thriller",
#   "10752": "war",
#   "37": "western"
# }