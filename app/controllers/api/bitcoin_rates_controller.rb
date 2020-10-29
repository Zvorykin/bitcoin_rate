# frozen_string_literal: true

class Api::BitcoinRatesController < ApiController
  PERIOD_LIMITS = {
    minute: 60 * 4,
    hour: 24 * 3,
    day: 31,
    week: 32
  }.freeze

  before_action :validate_params

  def index
    render json: BitcoinRateBlueprint.render(rates, root: :objects)
  end

  private

  def rates
    # period_start = DateTime.parse(params[:period_start])
    # period_end = DateTime.parse(params[:period_end])
    # quick fix to handle +03 timezone
    period_start = DateTime.parse(params[:period_start]) - 3.hours
    period_end = DateTime.parse(params[:period_end]) - 3.hours

    @rates ||= \
      BitcoinRate
      .where(period: params[:period])
      .where('period_start BETWEEN ? AND ?', period_start, period_end)
      .limit(limit)
  end

  def validate_params
    params.require(:period)
    params.require(:period_start)
    params.require(:period_end)
  end

  def limit
    PERIOD_LIMITS[params[:period].to_sym] || 32
  end
end
