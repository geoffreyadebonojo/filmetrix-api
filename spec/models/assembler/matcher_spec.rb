require 'rails_helper'
require 'spec_helper'

RSpec.describe Assembler::Matcher, type: :model do

  describe "in person-to-person matches" do
    it "doesn't find false positives" do
      credit_list = eval(File.read("spec/tom-cruise-kevin-hart-list.json").gsub("null", "nil"))
      matcher = Assembler::Matcher.new(credit_list)

      expect(matcher.found_matches).to eq([])
    end

    it "finds overlapping entries between two people" do
      credit_list = eval(File.read("spec/tom-cruise-brad-pitt-list.json").gsub("null", "nil"))
      matcher = Assembler::Matcher.new(credit_list)
      expected = ["movie-628", "movie-37757", "movie-126314", "movie-1113682"]

      expect(matcher.found_matches).to eq(expected)
    end

    it "finds overlapping entries between multiple people" do
      credit_list = eval(File.read("spec/tom-brad-morgan.json").gsub("null", "nil"))
      matcher = Assembler::Matcher.new(credit_list)
      expected = ["movie-74", "movie-628", "movie-75612", "movie-37757", "movie-126314", "movie-1113682", "movie-807", "movie-1242980"]

      expect(matcher.found_matches).to eq(expected)
    end
  end

  describe "in movie-to-movie matches" do
    it "doesn't find false positives" do
      credit_list = eval(File.read("spec/busan-mission-impossible-list.json").gsub("null", "nil"))
      matcher = Assembler::Matcher.new(credit_list)
      
      expect(matcher.found_matches).to eq([])
    end
    
    it "finds overlapping entries between two credit lists" do
      credit_list = eval(File.read("spec/vampire-mission-impossible-list.json").gsub("null", "nil"))
      matcher = Assembler::Matcher.new(credit_list)

      # more than are being shown on the graph...
      expected = ["person-500", "person-15320", "person-9028", "person-1836887", "person-10976", "person-44006", "person-1398107", "person-57569", "person-1394104", "person-1493890"]

      expect(matcher.found_matches).to eq(expected)
    end

    it "finds overlapping entries between multiple credit lists" do
      credit_list = eval(File.read("spec/se7en-vampire-oblivion-list.json").gsub("null", "nil"))
      matcher = Assembler::Matcher.new(credit_list)

      expected = ["person-192", "person-287", "person-6581", "person-7763", "person-1458993", "person-51333", "person-1691197", "person-1854468", "person-92303", "person-500", "person-14192", "person-1411066", "person-1428908", "person-1403415"]

      expect(matcher.found_matches).to eq(expected)
    end
  end

  xdescribe "in person-to-movie matches" do
    xit "finds overlapping entries between a person's and movie's credits" do
      # It very much looks like this cannot be done without querying TmdbService.discover for
      # each and every member of the cast/crew for a given movie...
    end
  end
end