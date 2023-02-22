class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.integer :movie_id, foreign_key: true, allow_nil: true
      t.integer :person_id, foreign_key: true, allow_nil: true
      t.text :roles
    end
  end
end
