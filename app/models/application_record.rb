class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def root
    "image.tmdb.org/t/p/w185_h278_bestv2"
  end
end
