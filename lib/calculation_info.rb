class CalculationInfo
  attr_reader :payed_credit_part, :payed_percent, :payed_full, :balance

  def initialize(payed_credit_part, payed_percent, payed_full, balance)
    @payed_credit_part = payed_credit_part
    @payed_percent = payed_percent
    @payed_full = payed_full
    @balance = balance
  end
end