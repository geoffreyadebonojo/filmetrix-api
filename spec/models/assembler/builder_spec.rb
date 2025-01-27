require 'rails_helper'
require 'spec_helper'

RSpec.describe Assembler::Builder, type: :model do
  describe ".assembled_response" do
    tc_details = Detail.new(
      eval(File.read("spec/fixtures/person-500-details.json").gsub("null", "nil"))
    )

    tc_credits_list = CreditList.new(
      eval(File.read("spec/fixtures/person-500-credits.json").gsub("null", "nil"))
    ).combined_credits

    bp_credits_list = CreditList.new(
      eval(File.read("spec/fixtures/person-287-credits.json").gsub("null", "nil"))
    ).combined_credits

    incoming_anchor = {
      anchor: tc_details,
      credits: tc_credits_list
    }

    inc = eval(File.read("spec/fixtures/builder/incoming-graph-data-one-entity.json").gsub("null", "nil")).first.deep_symbolize_keys

    builder = Assembler::Builder.new({
      anchor: Detail.new(inc[:anchor]), 
      credits: inc[:credtis]}
    )

    describe "for single anchor" do
      credit_list = [tc_credits_list]
      
      it "returns proper format" do
        response = builder.assembled_response(credit_list)
        
        expect(response[:id]).to eq("person-500")
        expect(response[:nodes]).to be_a(Array)
        expect(response[:links]).to be_a(Array)
        
        first_node = response[:nodes].first
        expect(first_node).to include(:id, :name, :poster, :entity, :type, :score)
        expect(first_node[:id]).to eq("person-500")
        expect(first_node[:poster]).to_not eq("")
        expect(first_node[:poster]).to_not eq(nil)
        expect(first_node[:entity]).to be_a(String)
        expect(first_node[:type]).to be_a(Array)
        expect(first_node[:score]).to be_a(Hash)
      end
      
      it "returns formatted with default number" do
        response = builder.assembled_response(credit_list)
        expect(response[:nodes].count).to eq(30)
        expect(response[:links].count).to eq(30)
      end

      it "returns formatted with the specified number" do
        response = builder.assembled_response(credit_list, {count: 20})
        
        expect(response[:nodes].count).to eq(20)
        expect(response[:links].count).to eq(20)
      end
    end

    describe "for multiple anchors" do 
      credit_list = tc_credits_list + bp_credits_list

      it "returns proper format" do
        response = builder.assembled_response(credit_list)
        expect(response[:id]).to eq("person-500")
        expect(response[:nodes]).to be_a(Array)
        expect(response[:links]).to be_a(Array)
        
        first_node = response[:nodes].first
        expect(first_node).to include(:id, :name, :poster, :entity, :type, :score)
        expect(first_node[:id]).to eq("person-500")
        expect(first_node[:poster]).to_not eq("")
        expect(first_node[:poster]).to_not eq(nil)
        expect(first_node[:entity]).to be_a(String)
        expect(first_node[:type]).to be_a(Array)
        expect(first_node[:score]).to be_a(Hash)

        second_node = response[:nodes].second
        expect(second_node).to include(:id, :name, :poster, :entity, :type, :score)
        expect(second_node[:id]).to eq("movie-74")
        expect(second_node[:poster]).to_not eq("")
        expect(second_node[:poster]).to_not eq(nil)
        expect(second_node[:entity]).to be_a(String)
        expect(second_node[:type]).to be_a(Array)
        expect(second_node[:score]).to be_a(Hash)
      end
      
      it "returns formatted with default number" do
        response = builder.assembled_response(credit_list)

        expect(response[:nodes].count).to eq(30)
        expect(response[:links].count).to eq(30)
      end

      it "returns formatted with the specified number" do
        response = builder.assembled_response(credit_list, {count: 20})
        
        expect(response[:nodes].count).to eq(20)
        expect(response[:links].count).to eq(20)
      end
    end
  end
end