class SavedGraph < ApplicationRecord
  validates_uniqueness_of :request_ids
end
