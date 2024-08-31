require 'rails_helper'
require 'spec_helper'

RSpec.describe AssembleGraphData, type: :model do
  describe "assembles" do
    
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }
    
    before(:each) do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end
    
    describe "properly attributes" do
      #fix this
      CreditList.destroy_all

      args = {ids: "person-500,movie-628"}
      
      args[:ids].split(",").each do |id|
        credit_list_hash = eval(File.read("spec/#{id}-credits.json").gsub("null", "nil"))
        cl = CreditList.create!({ id: id, body: credit_list_hash[:body] })
        Rails.cache.write("#{id}--credits", cl.grouped_credits)
      end
        
      it "all link sources" do
        graph_data = AssembleGraphData.execute(args)
        tc_links = graph_data.first[:links]
        expected = [{:source=>"person-500", :target=>"movie-74", :roles=>["Ray Ferrier"]},
                    {:source=>"person-500", :target=>"movie-180", :roles=>["Chief John Anderton [Pre-Crime]"]},
                    {:source=>"person-500", :target=>"movie-227", :roles=>["Steve Randle"]},
                    {:source=>"person-500", :target=>"movie-334", :roles=>["Frank T.J. Mackey"]},
                    {:source=>"person-500", :target=>"movie-345", :roles=>["Dr. William Harford"]},
                    {:source=>"person-500", :target=>"movie-380", :roles=>["Charlie Babbitt"]},
                    {:source=>"person-500", :target=>"movie-616", :roles=>["Nathan Algren", "Producer"]},
                    {:source=>"person-500", :target=>"movie-628", :roles=>["Lestat"]},
                    {:source=>"person-500", :target=>"movie-744", :roles=>["Maverick"]},
                    {:source=>"person-500", :target=>"movie-881", :roles=>["Lt. Daniel Kaffee"]},
                    {:source=>"person-500", :target=>"movie-955", :roles=>["Ethan Hunt", "Producer"]},
                    {:source=>"person-500", :target=>"movie-954", :roles=>["Ethan Hunt", "Producer"]},
                    {:source=>"person-500", :target=>"movie-956", :roles=>["Ethan Hunt", "Producer"]},
                    {:source=>"person-500", :target=>"movie-1538", :roles=>["Vincent"]},
                    {:source=>"person-500", :target=>"movie-1903", :roles=>["David Aames", "Producer"]},
                    {:source=>"person-500", :target=>"movie-2119", :roles=>["Cole Trickle", "Writer"]},
                    {:source=>"person-500", :target=>"movie-2253", :roles=>["Claus Schenk Graf von Stauffenberg"]},
                    {:source=>"person-500", :target=>"movie-2604", :roles=>["Ron Kovic"]},
                    {:source=>"person-500", :target=>"movie-10627", :roles=>["Cadet Captain David Shawn"]},
                    {:source=>"person-500", :target=>"movie-4515", :roles=>["Senator Jasper Irving", "Executive Producer"]},
                    {:source=>"person-500", :target=>"movie-11259", :roles=>["Joseph Donnelly"]},
                    {:source=>"person-500", :target=>"movie-7520", :roles=>["Brian Flanagan"]},
                    {:source=>"person-500", :target=>"movie-11873", :roles=>["Vincent Lauria"]},
                    {:source=>"person-500", :target=>"movie-11976", :roles=>["Jack"]},
                    {:source=>"person-500", :target=>"movie-9346", :roles=>["Joel Goodson"]},
                    {:source=>"person-500", :target=>"movie-9390", :roles=>["Jerry Maguire"]},
                    {:source=>"person-500", :target=>"movie-33676", :roles=>["Woody"]},
                    {:source=>"person-500", :target=>"movie-37233", :roles=>["Mitch McDeere"]},
                    {:source=>"person-500", :target=>"movie-37834", :roles=>["Roy Miller"]},
                    {:source=>"person-500", :target=>"movie-18172", :roles=>["Stefen Djordjevic"]}]

        expect(tc_links).to eq(expected)
      
        iwtv_links = graph_data.second[:links]
        expected = [{:source=>"person-17016", :target=>"movie-628", :roles=>["Director"]},
                    {:source=>"person-1493890", :target=>"movie-628", :roles=>["Additional Second Assistant Director"]},
                    {:source=>"person-1302", :target=>"movie-628", :roles=>["Casting"]},
                    {:source=>"person-1046", :target=>"movie-628", :roles=>["Casting"]},
                    {:source=>"person-500", :target=>"movie-628", :roles=>["Lestat"]},
                    {:source=>"person-287", :target=>"movie-628", :roles=>["Louis"]},
                    {:source=>"person-3131", :target=>"movie-628", :roles=>["Armand"]},
                    {:source=>"person-2224", :target=>"movie-628", :roles=>["Malloy"]},
                    {:source=>"person-9029", :target=>"movie-628", :roles=>["Santiago"]},
                    {:source=>"person-205", :target=>"movie-628", :roles=>["Claudia"]},
                    {:source=>"person-9031", :target=>"movie-628", :roles=>["Madeleine"]},
                    {:source=>"person-9030", :target=>"movie-628", :roles=>["Yvette"]},
                    {:source=>"person-149876", :target=>"movie-628", :roles=>["Mortal Woman on Stage"]},
                    {:source=>"person-16459", :target=>"movie-628", :roles=>["Gambler"]},
                    {:source=>"person-1218000", :target=>"movie-628", :roles=>["Tavern Girl"]},
                    {:source=>"person-2154797", :target=>"movie-628", :roles=>["Widow St. Clair"]},
                    {:source=>"person-81024", :target=>"movie-628", :roles=>["Piano Teacher"]},
                    {:source=>"person-15737", :target=>"movie-628", :roles=>["2nd Whore"]},
                    {:source=>"person-232174", :target=>"movie-628", :roles=>["New Orleans Whore"]},
                    {:source=>"person-1269309", :target=>"movie-628", :roles=>["Paris Vampire", "Choreographer"]},
                    {:source=>"person-15320", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-42571", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-199723", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-1434017", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-2107758", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-17290", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-207309", :target=>"movie-628", :roles=>["Paris Vampire"]},
                    {:source=>"person-24241", :target=>"movie-628", :roles=>["Estelle"]},
                    {:source=>"person-109377", :target=>"movie-628", :roles=>["Woman in Audience"]}]

        expect(iwtv_links).to eq(expected)

        # binding.pry
      end
    end
  end
end
