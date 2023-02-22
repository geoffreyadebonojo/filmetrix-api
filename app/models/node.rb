class Node < ApplicationRecord
  has_many :links, foreign_key: "source_id"
end
