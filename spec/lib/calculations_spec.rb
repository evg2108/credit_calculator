RSpec.describe Calculations do
  let(:random_percent_rate) { '%.2f' % ((rand(10_000) + 1) / 100) }
  let(:random_credit_sum) { '%.2f' % ((rand(1000_000_000) + 1) / 100) }
  let(:random_credit_period) { (rand(360) + 1).to_s }
  let(:random_credit_method) { rand(100) / 2 > 50 ? 'Usual' : 'Equal' }

  subject do
    Calculations.new('percent_rate'   => random_percent_rate,
                     'credit_sum'     => random_credit_sum,
                     'credit_period'  => random_credit_period,
                     'credit_method'  => random_credit_method)
  end

  it { is_expected.respond_to? :percent_rate }
  it { is_expected.respond_to? :credit_sum }
  it { is_expected.respond_to? :credit_period }
  it { is_expected.respond_to? :credit_method }

  describe '#percent_rate' do
    it 'is a BigDecimal' do
      expect(subject.percent_rate).to be_an(BigDecimal)
    end
  end

  describe '#credit_sum' do
    it 'is a BigDecimal' do
      expect(subject.credit_sum).to be_an(BigDecimal)
    end
  end

  describe '#credit_period' do
    it 'is a Integer' do
      expect(subject.credit_period).to be_an(Integer)
    end
  end

  describe '#credit_method' do
    it 'is a String' do
      expect(subject.credit_method).to be_an(String)
    end
  end

  describe '#run' do
    before(:example) { subject.run }

    it 'assigns collection' do
      expect(subject.instance_variable_get('@collection')).to match_array([instance_of(CalculationInfo)]*subject.credit_period)
    end
  end

  describe '#calculate_usual' do
    let(:month) { (subject.credit_period / 2).to_i }

    let(:payed_credit_part_result) { subject.credit_sum / subject.credit_period }
    let(:payed_percent_result) { ((subject.credit_sum - payed_credit_part_result * (month - 1)) / 12) * subject.percent_rate / 100 }
    let(:payed_full_result) { payed_credit_part_result + payed_percent_result }
    let(:balance_result) { subject.credit_sum - payed_credit_part_result * month }

    let(:calculate_usual_result) do
      subject.send(:calculate_usual, subject.credit_period, month, subject.percent_rate, subject.credit_sum)
    end

    it 'returns CalculationInfo instance' do
      expect(calculate_usual_result).to be_an CalculationInfo
    end

    it 'sets valid payed_credit_part for CalculationInfo instance' do
      expect(calculate_usual_result.payed_credit_part).to eq(payed_credit_part_result)
    end

    it 'sets valid payed_percent for CalculationInfo instance' do
      expect(calculate_usual_result.payed_percent).to eq(payed_percent_result)
    end

    it 'sets valid payed_full for CalculationInfo instance' do
      expect(calculate_usual_result.payed_full).to eq(payed_full_result)
    end

    it 'sets valid balance for CalculationInfo instance' do
      expect(calculate_usual_result.balance).to eq(balance_result)
    end
  end

  describe '#calculate_equal' do
    let(:rate) { subject.percent_rate / (12 * 100) }
    let(:coefficient) { (rate * (rate + 1) ** subject.credit_period) / ((rate + 1) ** subject.credit_period - 1) }

    let(:payed_full_result) { subject.credit_sum * coefficient }
    let(:payed_percent_result) { proc { |prev_balance| (prev_balance || subject.credit_sum) * rate } }
    let(:payed_credit_part_result) { proc { |prev_balance| payed_full_result - payed_percent_result.call(prev_balance) } }
    let(:balance_result) { proc { |prev_balance| (prev_balance || subject.credit_sum) - payed_credit_part_result.call(prev_balance) } }

    it 'returns CalculationInfo instance' do
      prev_balance = nil
      (1..subject.credit_period).to_a.each do
        calculate_equal_result = subject.send(:calculate_equal, subject.credit_period, subject.percent_rate, subject.credit_sum, prev_balance)
        expect(calculate_equal_result).to be_an CalculationInfo
        prev_balance = calculate_equal_result.balance
      end
    end

    it 'sets valid payed_credit_part for CalculationInfo instance' do
      prev_balance = nil
      (1..subject.credit_period).to_a.each do
        calculate_equal_result = subject.send(:calculate_equal, subject.credit_period, subject.percent_rate, subject.credit_sum, prev_balance)
        expect(calculate_equal_result.payed_credit_part).to eq(payed_credit_part_result.call(prev_balance))
        prev_balance = calculate_equal_result.balance
      end
    end

    it 'sets valid payed_percent for CalculationInfo instance' do
      prev_balance = nil
      (1..subject.credit_period).to_a.each do
        calculate_equal_result = subject.send(:calculate_equal, subject.credit_period, subject.percent_rate, subject.credit_sum, prev_balance)
        expect(calculate_equal_result.payed_percent).to eq(payed_percent_result.call(prev_balance))
        prev_balance = calculate_equal_result.balance
      end
    end

    it 'sets valid payed_full for CalculationInfo instance' do
      prev_balance = nil
      (1..subject.credit_period).to_a.each do
        calculate_equal_result = subject.send(:calculate_equal, subject.credit_period, subject.percent_rate, subject.credit_sum, prev_balance)
        expect(calculate_equal_result.payed_full).to eq(payed_full_result)
        prev_balance = calculate_equal_result.balance
      end
    end

    it 'sets valid balance for CalculationInfo instance' do
      prev_balance = nil
      (1..subject.credit_period).to_a.each do
        calculate_equal_result = subject.send(:calculate_equal, subject.credit_period, subject.percent_rate, subject.credit_sum, prev_balance)
        expect(calculate_equal_result.balance).to eq(balance_result.call(prev_balance))
        prev_balance = calculate_equal_result.balance
      end
    end
  end

  context do
    subject do
      Calculations.new('percent_rate'   => random_percent_rate,
                       'credit_sum'     => random_credit_sum,
                       'credit_period'  => '3',
                       'credit_method'  => random_credit_method)
    end

    before(:example) { subject.run }

    describe '#calculate_payed_credit_sum' do
      it 'returns sum of all payed credit values' do
        infos_collection = subject.instance_variable_get('@collection')
        expect(subject.calculate_payed_credit_sum).to eq(infos_collection[0].payed_credit_part +
                                                             infos_collection[1].payed_credit_part +
                                                             infos_collection[2].payed_credit_part)
      end
    end

    describe '#calculate_payed_percent_sum' do
      it 'returns sum of all payed percent values' do
        infos_collection = subject.instance_variable_get('@collection')
        expect(subject.calculate_payed_percent_sum).to eq(infos_collection[0].payed_percent +
                                                             infos_collection[1].payed_percent +
                                                             infos_collection[2].payed_percent)
      end
    end

    describe '#calculate_payed_full_sum' do
      it 'returns sum of all payed full sum values' do
        infos_collection = subject.instance_variable_get('@collection')
        expect(subject.calculate_payed_full_sum).to eq(infos_collection[0].payed_full +
                                                              infos_collection[1].payed_full +
                                                              infos_collection[2].payed_full)
      end
    end
  end
end