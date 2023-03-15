class Assembler
  attr_reader :incoming, :id, :anchor, :credits,
              :matches_for_anchor, :other,
              :inner_nodes, :inner_list

  def initialize(incoming)
    @id = incoming[:anchor].id
    @anchor = incoming[:anchor].data
    @credits = incoming[:credits]

    @inner_list = []
    @inner_nodes = []
    @matches_for_anchor = []
    @other = []
  end

  def add_matches
    @inner_list += matches_for_anchor
  end

  def add_other_nodes
    @inner_list += other
  end

  def define_anchor
    assembled = { id: id, 
      name: anchor[:name] || anchor[:title], 
      poster: anchor[:profile_path] || anchor[:poster_path],
      entity: anchor[:media_type] }
    
    if anchor[:media_type] == "person"
      assembled[:type] = [anchor[:known_for_department].downcase]
    else
      assembled[:type] = anchor[:genres].map{|x|genre_name(x[:id])}
    end

    inner_nodes << assembled
  end

  def assemble_credits(matches)
    if anchor[:media_type] == "person"
      credits.each do |credit|
        if credit[:genre_ids].exclude?(10402) && credit[:genre_ids].exclude?(99) && credit[:genre_ids].present?
          if matches.include?(credit[:id])
            matches_for_anchor << credit
          else
            other << credit
          end
        end
      end
    else
      credits.each.map do |y|
        other << y
      end
    end

    add_matches
    add_other_nodes
  end

  def genre_name(code)
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