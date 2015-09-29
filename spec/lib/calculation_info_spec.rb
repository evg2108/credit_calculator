RSpec.describe CalculationInfo do
  subject { CalculationInfo.new(instance_of(BigDecimal), instance_of(BigDecimal), instance_of(BigDecimal), instance_of(BigDecimal)) }

  it { is_expected.respond_to? :payed_credit_part }
  it { is_expected.respond_to? :payed_percent }
  it { is_expected.respond_to? :payed_full }
  it { is_expected.respond_to? :balance }
end