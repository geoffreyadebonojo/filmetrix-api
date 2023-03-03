class Search < ApplicationRecord

  def data
    self.body.deep_symbolize_keys
  end
end
