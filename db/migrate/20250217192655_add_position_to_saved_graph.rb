class AddPositionToSavedGraph < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_graphs, :position,  :text, array: true, default: []
  end
end
