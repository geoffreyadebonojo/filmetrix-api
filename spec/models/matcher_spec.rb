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
        
      credit_lists = CreditList.where(id: actor_ids).map do |x|
        x.grouped_credits
      end

      matcher = Matcher.new(credit_lists).matches

      expect(matcher.keys).to eq(matching_ids)
    end
  end
  
  describe "Formatter" do
    it "formats credit lists" do
      actor_ids = %w(person-500 person-287 person-192)

      credit_lists = CreditList.where(id: actor_ids).map do |x|
        x.grouped_credits
      end
        
      formatted = Formatter.new(credit_lists).format

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
end
