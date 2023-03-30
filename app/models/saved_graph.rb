class SavedGraph < ApplicationRecord
  validates_uniqueness_of :request_ids, :slug

  def filmetrix_link
    
    if Rails.env.production?
      url = "https://filmetrix.netlify.app/graph?gid=" if Rails.env.production?
    elsif Rails.env.development?
      url = "https://localhost:5173?gid=" if Rails.env.development?
    else
      raise "What... environment are you in?"
    end

    return url + self.slug
  end
end
