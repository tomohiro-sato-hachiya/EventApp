class CreateParticipants < ActiveRecord::Migration[6.0]
  def change
    create_table :participants do |t|
      t.integer :event_id
      t.integer :account_expanded_id
      t.integer :entry_status
      t.integer :participation_status

      t.timestamps
    end
  end
end
