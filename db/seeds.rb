# search_result = eval(File.read('./db/person-500-search-result.json'))
# TmdbService.build_from_results(search_result)

#####################################################################
tom_cruise = eval(File.read('./db/person-500-details.json'))
brad_pitt = eval(File.read('./db/person-287-details.json'))
morgan_freeman = eval(File.read('./db/person-192-details.json'))

Person.create!(tom_cruise)
Person.create!(brad_pitt)
Person.create!(morgan_freeman)

#####################################################################
wotw = eval(File.read('./db/movie-74-details.json'))
iwtv = eval(File.read('./db/movie-628-details.json'))

Movie.create!(wotw)
Movie.create!(iwtv)

#####################################################################
tc_movies = eval(File.read('./db/person-500-credits.json'))
bp_movies = eval(File.read('./db/person-287-credits.json'))
mf_movies = eval(File.read('./db/person-192-credits.json'))

TmdbService.generate_movie_credits(tc_movies, 500)
TmdbService.generate_movie_credits(bp_movies, 287)
TmdbService.generate_movie_credits(mf_movies, 192)

wotwC = eval(File.read('./db/movie-74-credits.json'))
