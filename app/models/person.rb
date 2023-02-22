class Person < ApplicationRecord
  has_many :links

  def full_id
    "person-#{id}"
  end

  def poster
    [root, profile_path].join
  end
end
