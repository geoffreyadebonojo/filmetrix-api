class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  
  has_many :user_saved_graphs
  has_many :saved_graphs, through: :user_saved_graphs

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
