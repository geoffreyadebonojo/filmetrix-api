class Movie < ApplicationRecord
  validates_uniqueness_of :_id

  has_many :user_movies
  has_many :users, through: :user_movies

  has_one :detail
  has_one :credit_list
end
