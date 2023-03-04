class Entity
  attr_reader :details, :credits, :credit_manager

  def initialize(id)
    @details = Detail.find!(id)
    @credits = CreditList.find!(id)

    if details.present? && credits.present?
      @credit_manager = credit_manager
    end
  end

  def credit_manager = CreditManager.new(
    details.anchor_data,
    credits_list.grouped_credits
  )
end