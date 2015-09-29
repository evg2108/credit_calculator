RSpec.describe FormatHelper do
  describe '#currency_format' do
    let(:dummy_class) { Class.new { include FormatHelper } }
    let(:number) { rand(10_000_000) }
    let(:formatted_str) { '%.2f' % number }

    it 'pass number and returns number as formatted string' do
      expect(dummy_class.new.currency_format(number)).to eq(formatted_str)
    end
  end
end