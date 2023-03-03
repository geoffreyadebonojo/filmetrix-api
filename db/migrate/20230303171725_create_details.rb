class CreateDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :details, id: :string do |t|
      t.json :body

      t.timestamps
    end
  end
end
