# frozen_string_literal: true

class CreateBitcoinRates < ActiveRecord::Migration[6.0]
  def change
    create_table :bitcoin_rates do |t|
      t.column :period, :string, null: false
      t.column :period_start, :datetime, index: true, null: false
      t.column :rate, :float, index: true, null: false

      t.timestamps
    end
  end
end
