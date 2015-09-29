RSpec.describe Calculations do
  subject do
    Calculations.new('percent_rate' => '%.2f' % ((rand(10_000) + 1) / 100),
                            'credit_sum' => '%.2f' % ((rand(1000_000_000) + 1) / 100),
                            'credit_period' => (rand(360) + 1).to_s,
                            'credit_method' => rand(100) / 2 > 50 ? 'Usual' : 'Equal')
    end

  it { is_expected.respond_to? :percent_rate }
  it { is_expected.respond_to? :credit_sum }
  it { is_expected.respond_to? :credit_period }
  it { is_expected.respond_to? :credit_method }

  describe '#percent_rate' do
    it 'is a BigDecimal' do
      expect(subject.percent_rate).to a_kind_of(BigDecimal)
    end
  end

  describe '#credit_sum' do
    it 'is a BigDecimal' do
      expect(subject.credit_sum).to a_kind_of(BigDecimal)
    end
  end

  describe '#credit_period' do
    it 'is a Integer' do
      expect(subject.credit_period).to a_kind_of(Integer)
    end
  end

  describe '#credit_method' do
    it 'is a String' do
      expect(subject.credit_method).to a_kind_of(String)
    end
  end
end