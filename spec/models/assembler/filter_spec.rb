require 'rails_helper'
require 'spec_helper'

RSpec.describe Assembler::Filter, type: :model do

  describe "filters" do
    movie_credits = eval(File.read("spec/fixtures/filter/oblivion-credits.json").gsub("null", "nil"))
    filter = Assembler::Filter.new(movie_credits, "film")
        
    describe "by department" do
      it "actors" do
        actors = filter.apply("Acting")

        expect(actors.count).to eq(9)

        tc = actors.first 

        expect(tc[:name]).to eq("Tom Cruise")
        expect(tc[:order]).to eq(0)
        expect(tc[:roles]).to eq(["Jack"])
        expect(tc[:departments]).to eq(["Acting"])
      end

      it "directors" do
        directors = filter.apply("Directing")

        expect(directors.count).to eq(3)

        jk = directors.first 

        expect(jk[:name]).to eq("Joseph Kosinski")
        # TODO: check that only actors have order
        # expect(jk[:order]).to eq(0)
        expect(jk[:roles]).to eq(["Original Story", "Director", "Producer"])
        expect(jk[:departments]).to eq(["Writing", "Directing", "Production"])
      end

      it "producers" do
        producers = filter.apply("Production")

        expect(producers.count).to eq(59)

        pc = producers.first 

        expect(pc[:name]).to eq("Peter Chernin")
        expect(pc[:roles]).to eq(["Producer"])
        expect(pc[:departments]).to eq(["Production"])
      end

      it "does overlaps" do
        directors = filter.apply("Directing")
        expect(directors.map{|d|d[:name]}).to include("Joseph Kosinski")

        producers = filter.apply("Production")
        expect(producers.map{|d|d[:name]}).to include("Joseph Kosinski")

        writers = filter.apply("Writing")
        expect(writers.map{|d|d[:name]}).to include("Joseph Kosinski")
      end
    end

    describe ".list_departments" do
      it "correctly lists all departments" do 
        depts = filter.list_departments
        expected = ["Acting",
          "Production",
          "Art",
          "Writing",
          "Directing",
          "Costume & Make-Up",
          "Crew",
          "Sound",
          "Editing",
          "Camera",
          "Lighting",
          "Visual Effects"]
        expect(depts).to eq(expected)
      end
    end

    describe ".gather( options )" do
      it "raises ArgumentError if one of the options is not a valid department name" do
        options = {directing: 1, acting: 3, writing: 1, fighting: 10}
        expect { filter.gather(options) }.to raise_error(ArgumentError)
      end

      it "returns a people without passing argument" do
        f = filter.gather

        expected = [["Writing", "Directing", "Production"],
        ["Production"],
        ["Production"],
        ["Writing"],
        ["Acting"],
        ["Acting"],
        ["Acting"],
        ["Acting"],
        ["Acting"],
        ["Acting"],
        ["Acting"],
        ["Acting"],
        ["Acting"]]

        expect(f.count).to eq(13)
        # more to consider here, with the way that these are counted and duplicates collapsed. 
        # !!May not always add up to the same total as in the options!!
        expect(f.map{|x|x[:departments]}).to eq(expected)
      end

      it "returns the right amount of people" do
        options = {directing: 1, acting: 3, writing: 1}
        f = filter.gather(options)

        expect(f.count).to eq(5)

        expected_names = ["Joseph Kosinski", "Tom Cruise", "Morgan Freeman", "Olga Kurylenko", "Michael Arndt"]
        expect(f.map{|x|x[:name]}).to eq(expected_names)
      end
    end

  end

end