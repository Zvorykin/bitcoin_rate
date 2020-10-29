# frozen_string_literal: true

class FetchBitcoinRateWorker
  include Sidekiq::Worker

  def perform
    rate = FetchBitcoinRate.new.call.result
    create_bitcoin_rate!(rate)
  end

  private

  def create_bitcoin_rate!(rate)
    BitcoinRate.create!(
      rate: rate,
      period: 'minute',
      period_start: Time.current.beginning_of_minute
    )
  end
end
