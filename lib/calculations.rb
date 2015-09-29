require 'bigdecimal'
require './lib/calculation_info'

class Calculations
  attr_reader :percent_rate, :credit_sum, :credit_period, :credit_method

  def initialize(params)
    @percent_rate = BigDecimal.new params['percent_rate']
    @credit_sum = BigDecimal.new params['credit_sum']
    @credit_period = params['credit_period'].to_i
    @credit_method = params['credit_method']
  end

  def run
    prev_balance = nil
    @collection = (1..credit_period).to_a.map do |month_index|
      case @credit_method
        when 'Usual'
          calculate_usual(credit_period, month_index, percent_rate, credit_sum)
        when 'Equal'
          info = calculate_equal(credit_period, percent_rate, credit_sum, prev_balance)
          prev_balance = info.balance
          info
      end
    end
  end

  def each(&method)
    @collection.each(&method)
  end

  def calculate_payed_credit_sum
    @collection.inject(0){ |sum, calc_info| sum + calc_info.payed_credit_part }
  end

  def calculate_payed_percent_sum
    @collection.inject(0){ |sum, calc_info| sum + calc_info.payed_percent }
  end

  def calculate_payed_full_sum
    @collection.inject(0){ |sum, calc_info| sum + calc_info.payed_full }
  end

  private

  def calculate_usual(credit_period, month, percent_rate, credit_sum)
    payed_credit_part = credit_sum / credit_period
    payed_percent = ((credit_sum - payed_credit_part * (month - 1)) / 12) * percent_rate / 100
    payed_full = payed_credit_part + payed_percent
    balance = credit_sum - payed_credit_part * month
    CalculationInfo.new(payed_credit_part, payed_percent, payed_full, balance)
  end

  def calculate_equal(credit_period, percent_rate, credit_sum, prev_balance)
    rate = percent_rate / (12 * 100)
    coefficient = (rate * (rate + 1) ** credit_period) / ((rate + 1) ** credit_period - 1)
    payed_full = credit_sum * coefficient

    payed_percent = (prev_balance || credit_sum) * rate

    payed_credit_part = payed_full - payed_percent

    balance = (prev_balance || credit_sum) - payed_credit_part
    CalculationInfo.new(payed_credit_part, payed_percent, payed_full, balance)
  end
end