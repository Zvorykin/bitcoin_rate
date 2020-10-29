# frozen_string_literal: true

require 'rails_helper'

describe FixMissingMinuteRatesService do
  describe '#call' do
    let(:check_time_start) { 7.minutes.ago }

    subject { described_class.new(check_time_start: check_time_start).call }

    context 'missing data for 5 minutes' do
      before do
        BitcoinRate.create!(
          [
            { rate: 1, period: 'minute', period_start: 7.minutes.ago.beginning_of_minute },
            { rate: 2, period: 'minute', period_start: 6.minutes.ago.beginning_of_minute },
            { rate: 4, period: 'minute', period_start: 1.minutes.ago.beginning_of_minute }
          ]
        )
      end

      it 'should create missing rates' do
        expect { subject }.to change { BitcoinRate.count }.from(3).to(7)

        minute_periods_starts = (1..7).map { |i| i.minutes.ago.beginning_of_minute }
        expect(BitcoinRate.pluck(:period_start)).to contain_exactly(*minute_periods_starts)
        expect(BitcoinRate.pluck(:rate)).to all((be >= 1.0).and(be <= 4.0))
      end
    end

    context 'missing fix starting time' do
      before do
        BitcoinRate.create!(
          [
            { rate: 1, period: 'minute', period_start: 8.minutes.ago.beginning_of_minute },
            { rate: 2, period: 'minute', period_start: 6.minutes.ago.beginning_of_minute }
          ]
        )
      end

      it 'should not create missing rates' do
        expect { subject }.to_not change { BitcoinRate.count }.from(2)
        expect(subject.error.first).to eq :missing_start_time
      end
    end

    context 'too much data missing' do
      let(:check_time_start) { 2.hours.ago }

      before do
        BitcoinRate.create!(
          [
            { rate: 1, period: 'minute', period_start: 3.hours.ago.beginning_of_minute }
          ]
        )
      end

      it 'should not create fake data because of limit' do
        expect { subject }.to_not change { BitcoinRate.count }.from(1)
        expect(subject.error.first).to eq :missing_start_time
      end
    end
  end
end
