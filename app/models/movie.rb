class Movie < ApplicationRecord
  belongs_to :user
  has_one :detail
  has_one :credit_list
end
