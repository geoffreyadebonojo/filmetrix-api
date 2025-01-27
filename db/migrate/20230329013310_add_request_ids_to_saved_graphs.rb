class AddRequestIdsToSavedGraphs < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_graphs, :request_ids, :string
  end
end
