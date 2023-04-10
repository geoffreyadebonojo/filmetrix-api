class AddMoviesToDetails < ActiveRecord::Migration[7.0]
  def change
    add_reference :details, :movie, index: true
    add_reference :credit_lists, :movie, index: true
  end
end
