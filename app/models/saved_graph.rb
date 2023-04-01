class SavedGraph < ApplicationRecord
  validates_uniqueness_of :existing, :slug

  def filmetrix_link
    if Rails.env.production?
      url = "https://filmetrix.netlify.app/graph?gid=" if Rails.env.production?
    elsif Rails.env.development?
      url = "http://localhost:5173/graph?gid=" if Rails.env.development?
    else
      raise "What... environment are you in?"
    end

    return url + self.slug
  end
end
