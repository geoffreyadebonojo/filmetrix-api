
list = %w(movie-11313)

list.each do |item|
  CreditList.create!(
    id: item,
    body: eval(File.read("db/seeds/#{item}/credit-list.json"))
  )

  Detail.create!(
    id: item,
    body: eval(File.read("db/seeds/#{item}/details.json"))
  )
end

