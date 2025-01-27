namespace :load_about do
  task :build => :environment do
    Detail.create!({
      id: "pierce",                          
      body:                                  
      {"overview"=>                         
        "Experienced designer specializing in marketing collateral materials and mass emails—internal and external, print and digital. From real estate and the mortgage industry to B2B and eCommerce; be it corporate and clean or something more creative and experimental, I love expanding a company's visual language and bringing the brand to life.",
        "media_type"=>"about",
        "name"=>"pierce",
        "poster"=>"/pierce-pixel.png"}
    })

    Detail.create!({
      id: "geoff",
      body:
      {"overview"=>
        "Rails • React • Ember • SCSS, SASS, CSS,etc. • Javascript/jQuery • RESTful JSON APIs Mysql • A/B Testing • Stripe pay processing • Jenkins CI • RSpec • Redis/ Sidekiq • Git/Github proficient • Kanban/Agile Web-scraping / data extraction DevOping public APIs Gathering and manipulating data Making visual maps Getting D3 to work half the time Finding excuses to use GraphQL Animations / natural simulations",
        "media_type"=>"about",
        "poster"=>"/geoff-pixel.png",
        "name"=>"geoff"}
    })

    Detail.create!({
      id: "filmetrix",                                                 
      body:                                                            
      {"title"=>"Filmetrix",                                          
        "overview"=>                                                   
        "Filmetrix visualizes data for networking movies and their cast and crew. The data comes from the wonderful TMDb API. The visualizations use the D3.js library (v4 if you want to know). So here's how it works. More or less. Click here when you're ready to get graphin'!",                                                        
        "media_type"=>"about",                                         
        "poster"=>"/filmetrix-logo.png"}
    })
  end
end
