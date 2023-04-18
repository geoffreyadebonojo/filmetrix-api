class UserSavedGraph < ApplicationRecord
  belongs_to :user
  belongs_to :saved_graph

  # add name possibility for user saved
end