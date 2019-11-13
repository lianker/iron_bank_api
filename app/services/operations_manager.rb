# frozen_string_literal: true

class OperationsManager
  def initialize; end

  def check_balance(account_number:)
    account = Account.find_by(number: account_number)
    return { error: true, data: 'account not found' } if account.nil?

    transactions = Transaction.where(account_id: account.id)
    return { data: { balance: 0.00 } } if transactions.nil?

    balance = transactions.inject(0) { |sum, item| sum + item.ammount }

    { data: { balance: balance } }
  end

  def api_check_balance(account_number:)
    balance_result = check_balance(account_number: account_number)

    return balance_result if balance_result[:error]

    { data: format_balance(balance_result) }
  end

  def format_balance(balance_result)
    "R$ #{format('$%.2f', balance_result[:data][:balance])}".gsub('.', ',')
  end
end
