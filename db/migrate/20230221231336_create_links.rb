class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.integer :movie_id, foreign_key: true, allow_nil: true
      t.integer :person_id, foreign_key: true, allow_nil: true
      t.string :roles, array: true, default: []
      t.integer :order
    end
  end
end
