class ChangeSavedGraphColumnName < ActiveRecord::Migration[7.0]
  def change
    change_table :saved_graphs do |t|
      t.rename :data, :body
    end
  end
end
