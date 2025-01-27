class CreateUserSavedGraphs < ActiveRecord::Migration[7.0]
  def change
    create_table :user_saved_graphs do |t|
      t.references :user
      t.references :saved_graph

      t.timestamps
    end
  end
end
