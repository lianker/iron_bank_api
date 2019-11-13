# frozen_string_literal: true

class OperationsManager
  def initialize; end

  def check_balance(account_number:)
    account = Account.find_by(number: account_number)
    return { error: true, data: 'account not found' } if account.nil?

    transactions = Transaction.find_by(account_id: account.id)
    return { data: { balance: 0.00 } } if transactions.nil?

    balance = transactions.inject(0) { |sum, item| sum + item.ammount }

    { data: { balance: balance } }
  end
end
