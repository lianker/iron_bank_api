class AddAccountToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_reference :transactions, :account, null: true, foreign_key: true
  end
end
