class Movie < ApplicationRecord
  has_many :links

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