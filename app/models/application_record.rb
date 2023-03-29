class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def data
    body = self.body

    if body.is_a? Array
      body.map(&:deep_symbolize_keys)
    elsif body.is_a? Hash
      body.deep_symbolize_keys
    end
    
  end
end
