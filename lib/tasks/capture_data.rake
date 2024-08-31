namespace :capture_data do
  task :details, [:id] => :environment do |t, args|
    data = Detail.find(args[:id])

		File.write("spec/#{args[:id]}-details.json", data.to_json)
  end
  
  task :credit_list, [:id] => :environment do |task, args|
    data = CreditList.find(args[:id])
    File.write("spec/#{args[:id]}-credits.json", data.to_json)
  end

  task :discover, [:ids] => :environment do |task, args|
    body = TmdbService.discover("500,287,192")
  end
end
