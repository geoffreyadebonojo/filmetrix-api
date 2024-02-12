class Friendship < ApplicationRecord
  belongs_to :user_a, :class_name => :User
  belongs_to :user_b, :class_name => :User

  def shared_graphs
    a_list = User.find(user_a_id).saved_graphs.pluck(:slug)
    b_list = User.find(user_b_id).saved_graphs.pluck(:slug)

    a_list & b_list
  end
end