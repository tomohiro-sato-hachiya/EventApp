class CreateAccountExpandeds < ActiveRecord::Migration[6.0]
  def change
    create_table :account_expandeds do |t|
      t.text :name
      t.integer :account_id

      t.timestamps
    end
  end
end
