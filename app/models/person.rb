class Person < ApplicationRecord
  has_many :links

  enum source: {
    "credits": 0,
    "search": 1,
    "details": 2
  }

  def full_id
    "person-#{id}"
  end

  def poster
    profile_path
  end
end
