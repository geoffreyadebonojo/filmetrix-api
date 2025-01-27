require 'rails_helper'
require 'spec_helper'

RSpec.describe Assembler::SearchResult, type: :model do

  describe "formats result" do

    it "for person search" do
      search_results = eval(File.read("spec/fixtures/search_results/tom-cruise.json").gsub("null", "nil"))
      assembled = Assembler::SearchResult.new(search_results)
      top_result = assembled.nodes.first

      expect(top_result.id).to eq("person-500")
      expect(top_result.media_type).to eq("person")
      expect(top_result.name).to eq("Tom Cruise")
      expect(top_result.poster).to_not be_nil
    end

    it "for movie search" do
      search_results = eval(File.read("spec/fixtures/search_results/se7en.json").gsub("null", "nil"))
      assembled = Assembler::SearchResult.new(search_results)
      top_result = assembled.nodes.first

      expect(top_result.id).to eq("movie-807")
      expect(top_result.media_type).to eq("movie")
      expect(top_result.name).to eq("Se7en")
      expect(top_result.poster).to_not be_nil
    end

    it "for ambiguous" do 
      search_results = eval(File.read("spec/fixtures/search_results/john-malkovich.json").gsub("null", "nil"))
      assembled = Assembler::SearchResult.new(search_results)

      assembled_names = assembled.nodes.map {|n| n.name }

      expect(assembled_names).to include("John Malkovich")
      expect(assembled_names).to include("Being John Malkovich")
    end
  end

end