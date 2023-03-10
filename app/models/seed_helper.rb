class SeedHelper
  def self.write(id)
    Dir.mkdir 'db/seeds/' + id
    CreditList.find(id).write
    Detail.find(id).write
  end
end