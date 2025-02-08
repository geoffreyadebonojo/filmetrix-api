class Assembler::Builder
  attr_reader :incoming, :id, :anchor, :credits,
              :matches_for_anchor, :other,
              :inner_nodes, :inner_links,
              :accepted_depts, :dept_limits

  attr_accessor :inner_list

  def initialize(incoming)
    @id = incoming[:anchor].id
    @anchor = incoming[:anchor].data
    @credits = incoming[:credits]

    @inner_list = []
    @inner_nodes = []
    @matches_for_anchor = []
    @other = []
    @inner_links = []
  end

  def assembled_response(credit_list, count)
    assemble_credits!(credit_list)
    assemble_inner_links!
    assemble_inner_nodes!

    {
      id:    id,
      nodes: inner_nodes.flatten.first(count),
      links: inner_links.flatten.first(count)
    }
  end

  private

  def define_genres(node)
    if node[:media_type] == "tv" 
      node[:genres].map{|x|x[:id]}
    elsif node[:media_type] == "movie"
      node[:genre_ids]
    end
  end

  def assemble_credits!(credit_list)
    define_anchor

    matches = Assembler::Matcher.new(credit_list).found_matches

    dirs = []
    wris = []
    scrn = []
    pros = []
    acts = []

    credits.each do |credit|
      genres = define_genres(credit)
      next unless certain_genres_excluded(genres)
      
      if matches.include?(credit[:id])
        matches_for_anchor << credit
      else
        if credit[:roles].include?("Director") && dirs.length < 1
          dirs << credit
        elsif credit[:roles].include?("Writer") && wris.length < 1
          wris << credit
        elsif (credit[:roles].include?("Screenplay") || credit[:roles].include?("Novel")) && scrn.length < 1
          scrn << credit
        elsif credit[:roles].include?("Producer") && pros.length < 1
          pros << credit
        elsif credit[:departments].include?("Acting")
          acts << credit
        else
          other << credit
        end
      end
    end

    credits = [
      dirs, 
      wris,
      scrn, 
      pros, 
      acts, 
      other
    ].flatten

    # binding.pry

    @inner_list += matches_for_anchor
    @inner_list += credits
  end

  def certain_genres_excluded(genres)
    genres.nil? || (genres.exclude?(10402) && genres.exclude?(99) && genres.present?)
  end

  def assemble_inner_links!
    filtered.each do |link|
      single_link(link)
    end
  end

  def assemble_inner_nodes!
    @inner_nodes << filtered.map do |node|
      single_node(node)
    end.flatten
  end

  def single_link(link)
    if anchor[:media_type] == "person"
      @inner_links << { 
        source: id, 
        target: link[:id], 
        roles: link[:roles]
      }
    else
      @inner_links << { 
        source: link[:id], 
        target: id, 
        roles: link[:roles]
      }
    end
  end

  def single_node(node)
    obj = { id: node[:id],
      name: node[:name],
      poster: node[:poster],
      type: node[:type],
    }

    if node[:media_type] == "person"
      obj[:type] = node[:departments].map{|x|x.gsub('\u0026', "&").downcase}
      obj[:score] = {
        popularity: node[:popularity]
      }
    else

      obj[:type] = define_genres(node) #node[:genre_ids].map{|x|genre_name(x)}
      obj[:score] = {
        popularity: node[:popularity],
        vote_average: node[:vote_average],
        vote_count: node[:vote_count]
      }
    end

    obj[:entity] = node[:media_type]
    
    obj
  end

  def filtered
    # Maybe in the future, include lower ranking connections
    # like dolly grip or whatever, who don't have posters
    # without counting them against the nodelimit
    # by rendering them as just dots
    # or
    # collapse them all into a single node

    inner_list
    # Assembler::Filter.new(inner_list, anchor[:media_type]).gather
  end

  def define_anchor
    anchor_node = { 
      id: id, 
      name: anchor[:name] || anchor[:title], 
      poster: anchor[:profile_path] || anchor[:poster_path],
      entity: anchor[:media_type]
    }
    
    if anchor[:media_type] == "person"
      anchor_node[:type] = [anchor[:known_for_department].downcase]
      anchor_node[:score] = { popularity: anchor[:popularity] }
    else
      anchor_node[:type] = anchor[:genres].map{|x|genre_name(x[:id])}
      anchor_node[:score] = {
        popularity: anchor[:popularity],
        vote_average: anchor[:vote_average],
        vote_count: anchor[:vote_count]
      }
    end

    @inner_nodes << anchor_node
  end

  def genre_name(code)
    # for movie, tv seems to have some differences
    vals = {
      28=> 'action',
      12=> 'adventure',
      16=> 'animation',
      35=> 'comedy',
      80=> 'crime',
      99=> 'documentary',
      18=> 'drama',
      10751=> 'family',
      14=> 'fantasy',
      36=> 'history',
      27=> 'horror',
      10402=> 'music',
      9648=> 'mystery',
      10749=> 'romance',
      878=> 'scifi',
      10770=> 'tvmovie',
      53=> 'thriller',
      10752=> 'war',
      37=> 'western'
    }
    vals[code]
  end
end