class AddExistingToSavedGraph < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_graphs, :existing, :text, array: true, default: []
  end
end
