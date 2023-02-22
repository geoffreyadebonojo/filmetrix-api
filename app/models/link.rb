class Link < ApplicationRecord
	belongs_to :movie, optional: true
	belongs_to :person, optional: true
end
