class RemoveUsersFromMovies < ActiveRecord::Migration[7.0]
  def change
    remove_column :movies, :user_id, :id
  end
end
