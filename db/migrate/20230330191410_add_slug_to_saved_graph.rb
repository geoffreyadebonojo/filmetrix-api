class AddSlugToSavedGraph < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_graphs, :slug, :string
  end
end
