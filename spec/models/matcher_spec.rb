require "pry"
require "rails_helper"


RSpec.describe "Assembly line", type: :model do

  before(:each) do
    tom_cruise_credits = CreditList.create!(
      id: "person-500",
      body: eval(File.read("db/seeds/person-500/credit-list.json"))
    )

    brad_pitt_credits = CreditList.create!(
      id: "person-287",
      body: eval(File.read("db/seeds/person-287/credit-list.json"))
    )

    morgan_freeman_credits = CreditList.create!(
      id: "person-192",
      body: eval(File.read("db/seeds/person-192/credit-list.json"))
    )
  end

  describe "Matcher" do
    it "finds overlaps" do
      actor_ids = %w(person-500 person-287 person-192)
      matching_ids = %w(movie-74 movie-75612 movie-628 
        movie-40196 movie-37757 movie-807 
        movie-744539)
        
      credit_lists = CreditList.where(id: actor_ids).map(&:grouped_credits)
      matcher = Matcher.new(credit_lists).matches

      expect(matcher.keys).to eq(matching_ids)
    end
  end
  
  describe "OrderedList" do
    it "formats credit lists" do
      actor_ids = %w(person-500 person-287 person-192)

      credit_lists = CreditList.where(id: actor_ids).map(&:grouped_credits)
        
      formatted = OrderedList.new(credit_lists).format

      tc_matches = formatted.first.first(10).map{|m|m[:id]}
      bp_matches = formatted.second.first(10).map{|m|m[:id]}
      mf_matches = formatted.third.first(10).map{|m|m[:id]}

      war_of_the_worlds = "movie-74"
      oblivion = "movie-75612"
      interview_with_a_vampire = "movie-628"
      se7en = "movie-807"

      expect(tc_matches).to include(war_of_the_worlds)
      expect(mf_matches).to include(war_of_the_worlds)

      expect(tc_matches).to include(oblivion)
      expect(mf_matches).to include(oblivion)

      expect(tc_matches).to include(interview_with_a_vampire)
      expect(bp_matches).to include(interview_with_a_vampire)

      expect(bp_matches).to include(se7en)
      expect(mf_matches).to include(se7en)
    end
  end

  describe "CreditCacheManager" do

    before do
      actor_ids = %w(person-500 person-287 person-192)
      @forbidden_genres = [99, 10402]
      @credit_cache_manager = CreditCacheManager.new(actor_ids, @forbidden_genres)
    end
    
    it "filters genres" do
      filtered_credits = @credit_cache_manager.filtered_credits

      tc_genres = filtered_credits["person-500"].map{|x|x[:genre_ids]}.flatten.uniq
      bp_genres = filtered_credits["person-287"].map{|x|x[:genre_ids]}.flatten.uniq
      mf_genres = filtered_credits["person-192"].map{|x|x[:genre_ids]}.flatten.uniq

      expect(tc_genres).to_not include(@forbidden_genres)
      expect(bp_genres).to_not include(@forbidden_genres)
      expect(mf_genres).to_not include(@forbidden_genres)
    end

    it "returns limited set" do
      tc_credits = @credit_cache_manager.return_cache_list_for_actor("person-500", 7)

      top_seven = ["War of the Worlds", "Oblivion", "Interview with the Vampire",
        "Minority Report", "Eyes Wide Shut", "The Last Samurai", "Top Gun"]

      expect(tc_credits.map{|x|x[:name]}).to eq(top_seven)
    end

    it "returns ordered set" do 
      
    end
  end
end
