# frozen_string_literal: true

class FixMissingRatesWorker
  include Sidekiq::Worker

  def perform
    FixMissingMinuteRatesService.new(check_time_start: 30.minutes.ago).call
    # TODO: we should calculate aggregate rates here but we will leave it for future commits
    # :)
  end
end
