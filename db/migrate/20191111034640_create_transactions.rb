class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.integer :source_account_id
      t.integer :destination_account_id
      t.float :ammount
      t.string :operation
      t.string :operation_type

      t.timestamps
    end
  end
end
