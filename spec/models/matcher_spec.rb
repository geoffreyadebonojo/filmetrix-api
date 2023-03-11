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

  describe "GenerateCreditsHash" do

    before do
      actor_ids = %w(person-500 person-287 person-192)
      @forbidden_genres = [99, 10402]
      @credit_cache_manager = GenerateCreditsHash.new(actor_ids, @forbidden_genres)
    end
    
    it "filters genres" do
      filtered_credits = @credit_cache_manager.filtered_credits_hash

      tc_genres = filtered_credits["person-500"].map{|x|x[:genre_ids]}.flatten.uniq
      bp_genres = filtered_credits["person-287"].map{|x|x[:genre_ids]}.flatten.uniq
      mf_genres = filtered_credits["person-192"].map{|x|x[:genre_ids]}.flatten.uniq

      expect(tc_genres).to_not include(@forbidden_genres)
      expect(bp_genres).to_not include(@forbidden_genres)
      expect(mf_genres).to_not include(@forbidden_genres)
    end

    it "returns limited set" do
      tc_credits = @credit_cache_manager.limit_count(actor_id: "person-500", count: 7)

      top_seven = ["War of the Worlds", "Oblivion", "Interview with the Vampire",
        "Minority Report", "Eyes Wide Shut", "The Last Samurai", "Top Gun"]

      expect(tc_credits.map{|x|x[:name]}).to eq(top_seven)
    end

    xit "returns ordered set" do 
      ordered_credits = @credit_cache_manager.ordered_credits_for_actor(
        actor_id: "person-500", 
        count: 7, 
        order_by: :popularity
      )

      top_seven_by_popularity = ["Top Gun", "Oblivion", "War of the Worlds",
        "Interview with the Vampire", "Eyes Wide Shut", "The Last Samurai",
        "Minority Report"]

      expect(ordered_credits.map{|x|x[:name]}).to eq(top_seven_by_popularity)
    end

    xit "can assemble credits into links and nodes" do
      actor_ids = %w(person-500 person-287 person-192)
      
      arg_id = "person-500"

      credits = GenerateCreditsHash.new(actor_ids).ordered_credits_for_actor(
        actor_id: arg_id, 
        count: 7, 
        order_by: :popularity
      )

      data = SingleEntityGraphData.new(arg_id, credits).data

      expected = {:nodes=> [
         {:id=>"movie-744",
          :name=>"Top Gun",
          :poster=>"/xUuHj3CgmZQ9P2cMaqQs4J0d4Zc.jpg",
          :type=>["action", "drama"],
          :entity=>"movie"},
         {:id=>"movie-75612",
          :name=>"Oblivion",
          :poster=>"/eO3r38fwnhb58M1YgcjQBd3VNcp.jpg",
          :type=>["action", "scifi", "adventure", "mystery"],
          :entity=>"movie"},
         {:id=>"movie-74",
          :name=>"War of the Worlds",
          :poster=>"/6Biy7R9LfumYshur3YKhpj56MpB.jpg",
          :type=>["adventure", "thriller", "scifi"],
          :entity=>"movie"},
         {:id=>"movie-628",
          :name=>"Interview with the Vampire",
          :poster=>"/2162lAT2MP36MyJd2sttmj5du5T.jpg",
          :type=>["horror", "drama", "fantasy"],
          :entity=>"movie"},
         {:id=>"movie-345",
          :name=>"Eyes Wide Shut",
          :poster=>"/knEIz1eNGl5MQDbrEAVWA7iRqF9.jpg",
          :type=>["drama", "thriller", "mystery"],
          :entity=>"movie"},
         {:id=>"movie-616",
          :name=>"The Last Samurai",
          :poster=>"/lsasOSgYI85EHygtT5SvcxtZVYT.jpg",
          :type=>["drama", "action", "war"],
          :entity=>"movie"},
         {:id=>"movie-180",
          :name=>"Minority Report",
          :poster=>"/ccqpHq5tk5W4ymbSbuoy4uYOxFI.jpg",
          :type=>["action", "thriller", "scifi", "mystery"],
          :entity=>"movie"}],
       :links=> [
         {:source=>"person-500",
          :target=>"movie-744",
          :roles=>["Lt. Pete 'Maverick' Mitchell"]},
         {:source=>"person-500", 
          :target=>"movie-75612", 
          :roles=>["Jack"]},
         {:source=>"person-500",
          :target=>"movie-74",
          :roles=>["Ray Ferrier"]},
         {:source=>"person-500",
          :target=>"movie-628",
          :roles=>["Lestat de Lioncourt"]},
         {:source=>"person-500",
          :target=>"movie-345",
          :roles=>["Dr. William Harford"]},
         {:source=>"person-500",
          :target=>"movie-616",
          :roles=>["Nathan Algren", "Producer"]},
         {:source=>"person-500",
          :target=>"movie-180",
          :roles=>["Chief John Anderton"]}]}

      expect(data).to eq(expected)
    end
  end
end
