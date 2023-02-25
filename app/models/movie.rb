class Movie < ApplicationRecord
  has_many :links
  has_many :people, through: :links

  enum source: {
    "credits": 0,
    "search": 1,
    "details": 2
  }

  def full_id
    "movie-#{id}"
  end

  def name
    title
  end

  def poster
    poster_path
  end
end