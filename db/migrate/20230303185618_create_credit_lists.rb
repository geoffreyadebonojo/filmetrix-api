class CreateCreditLists < ActiveRecord::Migration[7.0]
  def change
    create_table :credit_lists, id: :string do |t|
      t.json :body

      t.timestamps
    end
  end
end
