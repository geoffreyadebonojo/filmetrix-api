class TmdbService
	
	def self.search(term)

		# url = root + "/search/multi?" + key + query(term)
		# response = Faraday.get url
		# body = JSON.parse(response.body).deep_symbolize_keys
		body = obj

		results = body[:results]

		people = []
		movies = []
		tv =     []

		results.each do |r|
			if r[:media_type] == "person"
				people << r.except(:known_for)

				r[:known_for].each do |m|
					movies << m if m[:media_type] == "movie"
					tv << m     if m[:media_type] == "tv"
				end
			end

			movies << r if r[:media_type] == "movie"
			tv << r     if r[:media_type] == "tv"
		end
		
		binding.pry
	end
	
	def self.query(term)
		cleaned = term.downcase
		"&language=en-US&query=#{cleaned}&page=1&include_adult=false"
	end

	def self.root
		"https://api.themoviedb.org/3"
	end

	def self.key
		"api_key=a45442ace7db89ca6533dfeb22961976"
	end

	def self.obj 
		{"page": 1,
	"results": 
	 [{"adult": false,
		 "id": 500,
		 "name": "Tom Cruise",
		 "original_name": "Tom Cruise",
		 "media_type": "person",
		 "popularity": 35.196,
		 "gender": 2,
		 "known_for_department": "Acting",
		 "profile_path": "/8qBylBsQf4llkGrWR3qAsOtOU8O.jpg",
		 "known_for": 
			[{"adult": false,
				"backdrop_path": "/4V1yIoAKPMRQwGBaSses8Bp2nsi.jpg",
				"id": 137113,
				"title": "Edge of Tomorrow",
				"original_language": "en",
				"original_title": "Edge of Tomorrow",
				"overview": 
				 "Major Bill Cage is an officer who has never seen a day of combat when he is unceremoniously demoted and dropped into combat. Cage is killed within minutes, managing to take an alpha alien down with him. He awakens back at the beginning of the same day and is forced to fight and die again... and again - as physical contact with the alien has thrown him into a time loop.",
				"poster_path": "/xjw5trHV7Mwo61P0kCTy8paEkgO.jpg",
				"media_type": "movie",
				"genre_ids": [28, 878],
				"popularity": 50.116,
				"release_date": "2014-05-27",
				"video": false,
				"vote_average": 7.596,
				"vote_count": 12291},
			 {"adult": false,
				"backdrop_path": "/19AqfWi8S99tDmp7hskCeDQuwLU.jpg",
				"id": 75612,
				# "title": "Oblivion",


				"overview": 
				 "Jack Harper is one of the last few drone repairmen stationed on Earth. Part of a massive operation to extract vital resources after decades of war with a terrifying threat known as the Scavs, Jack’s mission is nearly complete. His existence is brought crashing down when he rescues a beautiful  stranger from a downed spacecraft. Her arrival triggers a chain of events that  forces him to question everything he knows and puts the fate of humanity in his hands.",
				"poster_path": "/eO3r38fwnhb58M1YgcjQBd3VNcp.jpg",
				# "media_type": "movie",
				# "genre_ids": [28, 878, 12, 9648],
				# "popularity": 36.212,
				# "release_date": "2013-04-10",
				"video": false,
				"vote_average": 6.608,
				"vote_count": 9690},
			 {"adult": false,
				"backdrop_path": "/hqyjzDRCs1N5gEsh2gklzPdsEFD.jpg",
				"id": 56292,
				"title": "Mission: Impossible - Ghost Protocol",
				"original_language": "en",
				"original_title": "Mission: Impossible - Ghost Protocol",
				"overview": 
				 "Ethan Hunt and his team are racing against time to track down a dangerous terrorist named Hendricks, who has gained access to Russian nuclear launch codes and is planning a strike on the United States. An attempt to stop him ends in an explosion causing severe destruction to the Kremlin and the IMF to be implicated in the bombing, forcing the President to disavow them. No longer being aided by the government, Ethan and his team chase Hendricks around the globe, although they might still be too late to stop a disaster.",
				"poster_path": "/psiWp3VTjznfokmGQG9uqiiknQQ.jpg",
				"media_type": "movie",
				"genre_ids": [28, 53, 12],
				"popularity": 52.961,
				"release_date": "2011-12-07",
				"video": false,
				"vote_average": 7.05,
				"vote_count": 8715}]},
		{"adult": false,
		 "backdrop_path": "/uRokRYuqQZf5v1JJERKhKTmJXLn.jpg",
		 "id": 984430,
		 "title": "James Corden's Top Gun Training with Tom Cruise",
		 "original_language": "en",
		 "original_title": "James Corden's Top Gun Training with Tom Cruise",
		 "overview": "When \"Top Gun: Maverick\" star Tom Cruise calls you up to hang out for the day, you say yes. And for James Corden, that meant having Tom pilot you in two different fighter planes, pushing the limits of gravity and James's stomach.",
		 "poster_path": "/e2EILRtu7b6qu4TuwU7BpyHop68.jpg",
		 "media_type": "movie",
		 "genre_ids": [28, 35, 99],
		 "popularity": 24.267,
		 "release_date": "2022-06-01",
		 "video": false,
		 "vote_average": 6.143,
		 "vote_count": 14},
		{"adult": false,
		 "backdrop_path": "/kThxkMh2hNTUzFqPp72GfvXf5x0.jpg",
		 "id": 765522,
		 "title": "Tom Cruise: An Eternal Youth",
		 "original_language": "en",
		 "original_title": "Tom Cruise: An Eternal Youth",
		 "overview": 
			"After 40 years, Tom Cruise continues to push the envelope in film. Exposing ones' heart to the world through their work is not only risky business, as far as Cruise is concerned, it is the only way to achieve an end that feels complete.",
		 "poster_path": "/MQwWS1iBzUkpyjNFV8Je6dFoIU.jpg",
		 "media_type": "movie",
		 "genre_ids": [99],
		 "popularity": 5.653,
		 "release_date": "2020-10-05",
		 "video": false,
		 "vote_average": 6.694,
		 "vote_count": 18},
		{"adult": false,
		 "backdrop_path": nil,
		 "id": 1010758,
		 "title": "Untitled Tom Cruise and Christopher McQuarrie Musical",
		 "original_language": "en",
		 "original_title": "Untitled Tom Cruise and Christopher McQuarrie Musical",
		 "overview": "An \"original song and dance-style musical\" by Christopher McQuarrie and Tom Cruise.",
		 "poster_path": nil,
		 "media_type": "movie",
		 "genre_ids": [10402],
		 "popularity": 0.915,
		 "release_date": "",
		 "video": false,
		 "vote_average": 0.0,
		 "vote_count": 0},
		{"adult": false,
		 "backdrop_path": nil,
		 "id": 1010759,
		 "title": "Untitled Tom Cruise and Christopher McQuarrie Action Film",
		 "original_language": "en",
		 "original_title": "Untitled Tom Cruise and Christopher McQuarrie Action Film",
		 "overview": "An \"original action film with franchise potential\" by Christopher McQuarrie and Tom Cruise.",
		 "poster_path": nil,
		 "media_type": "movie",
		 "genre_ids": [28],
		 "popularity": 0.6,
		 "release_date": "",
		 "video": false,
		 "vote_average": 0.0,
		 "vote_count": 0},
		{"adult": false,
		 "backdrop_path": "/mpJwppwUCtV5cGjb6wYF7p219S2.jpg",
		 "id": 53849,
		 "title": "Cruise Cat",
		 "original_language": "en",
		 "original_title": "Cruise Cat",
		 "overview": 
			"Tom is the official cat on the cruise ship S.S. Aloha, but he'll be kicked off if the captain finds even one mouse. That one, of course, is Jerry, who sneaks on board just before sailing.",
		 "poster_path": "/vQpmz4zCHxRYOQMQUgS373bSZvt.jpg",
		 "media_type": "movie",
		 "genre_ids": [16, 35],
		 "popularity": 3.132,
		 "release_date": "1952-10-18",
		 "video": false,
		 "vote_average": 6.6,
		 "vote_count": 31}],
	"total_pages": 1,
	"total_results": 6
 }
end
end
 
