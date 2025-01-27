class FixColumnName < ActiveRecord::Migration[7.0]
  def change
    change_table :user_movies do |t|
      t.rename :movies_id, :movie_id
    end
  end
end
