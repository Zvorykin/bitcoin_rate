# frozen_string_literal: true

MINUTES_IN_YEAR = 60 * 24 * 365
# MINUTES_IN_YEAR = 10_000
YEAR_AGO = 1.year.ago.beginning_of_minute

# perhaps seeding will be faster if we will drop indexes and recreate it after seeding
# create minute rates
rates = []
p "Going to create #{MINUTES_IN_YEAR} records. This should take some time..."
MINUTES_IN_YEAR.times do |minute_index|
  rates << {
    period: 'minute',
    rate: rand(1_300.00..10_000.00),
    period_start: YEAR_AGO + minute_index.minutes
  }
  next unless (minute_index % 1_000).zero? && minute_index.positive?

  BitcoinRate.create!(rates)
  rates = []
  p "#{minute_index} records generated"
end
BitcoinRate.create!(rates) if rates.any?
p "#{BitcoinRate.count} totally generated"

(1..12).each do |month_index|
  p "create hourly average rates for month number #{month_index}"

  sql = <<-SQL
  SELECT AVG(rate) as rate,
    to_char(period_start, 'YYYY-MM-DD HH24:00:00') as period_start_alias,
    'hour' as period
    FROM bitcoin_rates
    WHERE EXTRACT(MONTH FROM period_start) = #{month_index} AND period = 'minute'
    GROUP BY period_start_alias
  SQL

  average_hour_rates = ActiveRecord::Base.connection.execute(sql).to_a
  BitcoinRate.create!(average_hour_rates)
end

p 'create daily average rates'
sql = <<-SQL
  SELECT AVG(rate) as rate,
  to_char(period_start, 'YYYY-MM-DD 00:00:00') as period_start_alias,
  'day' as period
  FROM bitcoin_rates
  WHERE period = 'hour'
  GROUP BY period_start_alias
SQL

average_day_rates = ActiveRecord::Base.connection.execute(sql).to_a
BitcoinRate.create!(average_day_rates)

p 'create weekly rates'
sql = <<-SQL
  SELECT AVG(rate) as rate,
  date_trunc('week', period_start) as period_start_alias,
  'week' as period
  FROM bitcoin_rates
  WHERE period = 'day'
  GROUP BY period_start_alias
SQL

average_week_rates = ActiveRecord::Base.connection.execute(sql).to_a
BitcoinRate.create!(average_week_rates)

p 'create month average rates'
sql = <<-SQL
  SELECT AVG(rate) as rate,
  to_char(period_start, 'YYYY-MM-01 00:00:00') as period_start_alias,
  'month' as period
  FROM bitcoin_rates
  WHERE period = 'week'
  GROUP BY period_start_alias
SQL

average_month_rates = ActiveRecord::Base.connection.execute(sql).to_a
BitcoinRate.create!(average_month_rates)

p 'create year average rates'
sql = <<-SQL
  SELECT AVG(rate) as rate,
  to_char(period_start, 'YYYY-01-01 00:00:00') as period_start_alias,
  'year' as period
  FROM bitcoin_rates
  WHERE period = 'month'
  GROUP BY period_start_alias
SQL

average_month_rates = ActiveRecord::Base.connection.execute(sql).to_a
BitcoinRate.create!(average_month_rates)

