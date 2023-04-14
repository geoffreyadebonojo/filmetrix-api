class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  
  has_many :user_saved_graphs
  has_many :saved_graphs, through: :user_saved_graphs

  has_many :user_movies
  has_many :movies, through: :user_movies

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self


  # TODO:
  # add username
  # store robothash to preserve profile image even if username is reset
  # also add option to regenerate another robot profile image
  # faker to auto-generate username
end
