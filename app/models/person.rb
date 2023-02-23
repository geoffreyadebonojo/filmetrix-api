class Person < ApplicationRecord
  has_many :links

  def full_id
    "person-#{id}"
  end

  def poster
    profile_path
  end
end
