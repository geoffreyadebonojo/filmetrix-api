class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  
  has_many :user_saved_graphs
  has_many :saved_graphs, through: :user_saved_graphs

  has_many :user_movies
  has_many :movies, through: :user_movies

  has_many :friendships, :foreign_key => :user_a
  has_many :users, :through => :friendships, :source => :user_b

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self


  # TODO:
  # add username
  # store robothash to preserve profile image even if username is reset
  # also add option to regenerate another robot profile image
  # faker to auto-generate username

  before_save :generate_profile_img

  def generate_profile_img
    self.profile_img = "https://robohash.org/#{self.email}.png?set=set3"
  end
end
