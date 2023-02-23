class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.integer :source
      t.boolean :adult
      t.string :also_known_as, array: true, default: []
      t.string :biography
      t.date :birthday
      t.date :deathday
      t.string :name
      t.string :original_name
      t.string :homepage
      t.string :imdb_id
      t.string :media_type
      t.float :popularity
      t.string :place_of_birth
      t.integer :gender
      t.string :known_for_department
      t.string :profile_path
    end
  end
end

