class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.references :user
      
      t.string :_id
      t.string :title
      t.string :poster

      t.timestamps
    end
  end
end
