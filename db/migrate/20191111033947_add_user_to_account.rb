class AddUserToAccount < ActiveRecord::Migration[6.0]
  def change
    add_reference :accounts, :user, null: true, foreign_key: true
  end
end
