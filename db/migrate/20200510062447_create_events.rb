class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.text :name
      t.text :detail
      t.integer :place_id
      t.integer :account_expanded_id
      t.text :address
      t.text :online
      t.datetime :event_start_datetime
      t.datetime :event_end_datetime
      t.datetime :entry_start_datetime
      t.datetime :entry_end_datetime

      t.timestamps
    end
  end
end
