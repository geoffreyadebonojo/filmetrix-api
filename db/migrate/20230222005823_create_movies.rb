class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.boolean :adult
      t.string :backdrop_path
      t.json :belongs_to_collection
      t.integer :budget
      t.json :genres, array: true, default: []
      t.string :homepage
      t.string :title
      t.string :imdb_id
      t.string :original_language
      t.string :original_title
      t.text :overview
      t.string :poster_path
      t.json :production_companies, array: true, default: []
      t.json :production_countries, array: true, default: []
      t.string :media_type
      t.integer :genre_ids, array: true, default: []
      t.float :popularity
      t.date :release_date
      t.integer :revenue
      t.integer :runtime
      t.json :spoken_languages, array: true, default: []
      t.string :status
      t.string :tagline
      t.boolean :video
      t.float :vote_average
      t.integer :vote_count
    end
  end
end
