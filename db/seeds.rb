# search_result = eval(File.read('./db/person-500-search-result.json'))
# TmdbService.build_from_results(search_result)

tom_cruise = eval(File.read('./db/person-500.json'))
brad_pitt = eval(File.read('./db/person-287.json'))

Person.create!(tom_cruise)
Person.create!(brad_pitt)

wotw = eval(File.read('./db/movie-74.json'))
iwtv = eval(File.read('./db/movie-628.json'))

Movie.create!(wotw)
Movie.create!(iwtv)

tc_links = eval(File.read('./db/person-500-links.json'))
Link.insert_all!(tc_links)