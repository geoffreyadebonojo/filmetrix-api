class Assembler::Builder
  attr_reader :incoming, :id, :entity, :full_id, :anchor, :credits,
              :matches_for_anchor, :other,
              :inner_nodes, :inner_links,
              :accepted_depts, :dept_limits

  attr_accessor :inner_list

  def initialize(incoming)
    @id = incoming[:anchor][:id]
    @entity = incoming[:anchor][:media_type]
    @full_id = "#{@entity}-#{@id}"
    @anchor = incoming[:anchor]
    @credits = incoming[:credits]
    @inner_list = []
    @inner_nodes = []
    @matches_for_anchor = []
    @other = []
    @inner_links = []
  end

  def node_is?(type, node)
    node[:media_type] == type
  end

  def assembled_response(credit_list, count)
    assemble_credits!(credit_list)
    assemble_inner_links!
    assemble_inner_nodes!

    {
      id:    full_id,
      nodes: inner_nodes.flatten,#.first(count),
      links: inner_links.flatten#.first(count)
    }
  end

  private

  def define_genres(node)
    if node_is?("tv", node)
      node[:genres].map{|x|x[:id]}
    elsif node_is?("movie", node)
      node[:genre_ids].map{|x|genre_name(x)}
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
      if !credit[:genre_ids].nil?
        next if credit[:genre_ids].empty?
        next if credit[:genre_ids].include?(10402)
        next if credit[:genre_ids].include?(99)
      end

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

    sorted_credits = [dirs, wris,scrn, pros, acts, other].flatten
    @inner_list = [matches_for_anchor, sorted_credits].flatten
  end

  def assemble_inner_links!
    inner_list.each do |link|
      single_link(link)
    end
  end

  def assemble_inner_nodes!
    @inner_nodes << inner_list.map do |node|
      single_node(node)
    end.flatten
  end

  def single_link(link)
    # if node_is?("person", anchor)
      @inner_links << { 
        source: full_id, 
        target: link[:id], 
        roles: link[:roles]
      }
    # else
    #   @inner_links << { 
    #     source: link[:id], 
    #     target: full_id, 
    #     roles: link[:roles]
    #   }
    # end
  end

  def single_node(node)
    obj = { id: node[:id],
      name: node[:name],
      poster: node[:poster],
      type: [],
    }

    if node_is?("person", node)
      obj[:type] = node[:departments].map{|x|x.gsub('\u0026', "&").downcase}
      obj[:score] = {
        popularity: node[:popularity]
      }
    elsif node_is?("tv", node)
      obj[:type] = define_genres(node)
      obj[:score] = {
        popularity: node[:popularity],
        vote_average: node[:vote_average],
        vote_count: node[:vote_count]
      }
    elsif node_is?("movie", node)
      obj[:type] = define_genres(node)
      obj[:score] = {
        popularity: node[:popularity],
        vote_average: node[:vote_average],
        vote_count: node[:vote_count]
      }
    end

    obj[:entity] = node[:media_type]
    obj
  end

  def define_anchor
    anchor_node = { 
      id: full_id, 
      name: anchor[:name] || anchor[:title], 
      poster: anchor[:profile_path] || anchor[:poster_path],
      entity: anchor[:media_type]
    }
    
    if node_is?("person", anchor)
      anchor_node[:type] = [anchor[:known_for_department].downcase]
      anchor_node[:score] = { popularity: anchor[:popularity] }
    
    elsif node_is?("tv", anchor)
      anchor_node[:type] = anchor[:genres].map{ |x|x[:name].downcase }.join(" ").gsub("& ", "").split(" ").uniq
      anchor_node[:score] = {
        popularity: anchor[:popularity],
        vote_average: anchor[:vote_average],
        vote_count: anchor[:vote_count]
      }
      
    elsif node_is?("movie", anchor)
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