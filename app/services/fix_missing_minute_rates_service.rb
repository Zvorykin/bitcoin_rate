# frozen_string_literal: true

class FixMissingMinuteRatesService
  MISSING_RECORDS_LIMIT = 240

  attr_reader :error

  def initialize(check_time_start:)
    @check_time = check_time_start.beginning_of_minute
  end

  # maybe we should use history API to get missing data but let's suppose this API does not exists
  # then we have to create fake data just to fill the chart gaps

  def call
    start_rate = BitcoinRate.find_by(period: 'minute', period_start: @check_time)
    if start_rate.nil?
      @error = [:missing_start_time, 'Start time rate missing, try to start fixing earlier']
      return self
    end

    missing_records_counter = 0
    until @check_time >= Time.current.beginning_of_minute
      @check_time += 1.minute

      rate_to_check = BitcoinRate.find_by(period: 'minute', period_start: @check_time)
      if rate_to_check.nil?
        missing_records_counter += 1
        next if missing_records_counter < MISSING_RECORDS_LIMIT

        @error = [:too_much_missing_records, 'Too much missing records, please add data by hand']
        return self
      end

      next if rate_to_check && missing_records_counter.zero?

      create_missing_rates(start_rate, rate_to_check, missing_records_counter)
      start_rate = rate_to_check
      missing_records_counter = 0
    end
  end

  private

  def create_missing_rates(start_rate, end_rate, amount)
    sorted_rates = [end_rate.rate, start_rate.rate].sort
    rate_range = sorted_rates.first..sorted_rates.last
    fake_rates_attrs = (1..amount).each_with_object([]) do |record_index, acc|
      acc << {
        period: 'minute',
        rate: rand(rate_range),
        period_start: start_rate.period_start + (record_index + 1).minutes
      }
    end

    BitcoinRate.create!(fake_rates_attrs)
  end
end
