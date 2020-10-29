# frozen_string_literal: true

require 'faraday'

class FetchBitcoinRate
  attr_reader :result

  def call
    @result = fetch_rate

    self
  end

  private

  def client
    @client ||= Faraday.new(
      url: 'https://pro-api.coinmarketcap.com',
      params: {
        limit: 1,
        convert: 'USD'
      },
      headers: { 'X-CMC_PRO_API_KEY' => ENV['COINMARKET_API_KEY'] }
    )
  end

  def fetch_rate
    response = client.get('v1/cryptocurrency/listings/latest')

    data = JSON.parse(response.body)
    data.dig('data', 0, 'quote', 'USD', 'price')
  end
end
