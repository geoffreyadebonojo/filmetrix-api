require 'rails_helper'
require 'spec_helper'

RSpec.describe Assembler::Matcher, type: :model do

  xit "doesn't find false positives" do

  end

  it "finds overlapping entries between two credit lists" do
    credit_list = eval(File.read("spec/tom-cruise-brad-pitt-list.json").gsub("null", "nil"))
    matcher = Assembler::Matcher.new(credit_list)

    expect(matcher.found_matches).to eq(["movie-628", "movie-37757", "movie-126314", "movie-1113682"])
  end

  it "finds overlapping entries between multiple credit lists" do
    credit_list = eval(File.read("spec/tc-bp-mf.json").gsub("null", "nil"))
    matcher = Assembler::Matcher.new(credit_list)
    expected = ["movie-74", "movie-628", "movie-75612", "movie-37757", "movie-126314", "movie-1113682", "movie-807", "movie-1242980"]

    expect(matcher.found_matches).to eq(expected)
  end
end