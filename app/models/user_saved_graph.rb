class UserSavedGraph < ApplicationRecord
  belongs_to :user
  belongs_to :saved_graph
end