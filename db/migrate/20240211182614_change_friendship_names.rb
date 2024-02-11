class ChangeFriendshipNames < ActiveRecord::Migration[7.0]
  def change
    change_table :friendships do |t|
      t.rename :friend_a_id, :user_a_id
      t.rename :friend_b_id, :user_b_id
    end
  end
end
