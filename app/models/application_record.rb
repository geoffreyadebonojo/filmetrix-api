class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def data
    self.body.deep_symbolize_keys
  end
end
