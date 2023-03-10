require "pry"
require "rails_helper"


RSpec.describe "Matcher", type: :model do
  describe "works" do
    it "finds overlaps" do

      list = %w(person-500 person-287 person-192)

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

      matcher = Matcher.new(list).overlapping_entities

      matching_ids = ["movie-74", "movie-75612", "movie-628", 
                      "movie-40196", "movie-37757", "movie-807", 
                      "movie-744539"]

      expect(matcher.keys).to eq(matching_ids)
    end
  end
end
