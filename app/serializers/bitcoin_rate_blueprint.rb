# frozen_string_literal: true

class BitcoinRateBlueprint < Blueprinter::Base
  identifier :id

  fields :period, :period_start, :rate

  field :rate do |object|
    object.rate.round(2)
  end
end
