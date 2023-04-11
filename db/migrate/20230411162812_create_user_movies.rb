class CreateUserMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :user_movies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movies, null: false, foreign_key: true

      t.timestamps
    end
  end
end
