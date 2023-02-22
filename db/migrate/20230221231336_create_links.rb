class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.integer :source_id, foreign_key: true
      t.integer :target_id, foreign_key: true
      t.text :roles
    end
  end
end
