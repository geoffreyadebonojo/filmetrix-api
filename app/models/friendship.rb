class Friendship < ApplicationRecord
  belongs_to :user_a, :class_name => :User
  belongs_to :user_b, :class_name => :User
end