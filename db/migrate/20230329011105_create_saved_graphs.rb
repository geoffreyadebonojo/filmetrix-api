class CreateSavedGraphs < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_graphs do |t|
      t.json :data

      t.timestamps
    end
  end
end
