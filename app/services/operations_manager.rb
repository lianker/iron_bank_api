# frozen_string_literal: true

# Manage account operations
class OperationsManager
  def initialize; end

  def check_balance(account_number:)
    account = validate_account(account_number, 'account not found')

    transactions = Transaction.where(account_id: account.id)
    return { data: { balance: 0.00 } } if transactions.nil?

    balance = transactions.inject(0) { |sum, item| sum + item.ammount }

    { data: { balance: balance } }
  rescue RuntimeError => e
    { error: true, data: e.message }
  end

  def api_check_balance(account_number:)
    balance_result = check_balance(account_number: account_number)

    return balance_result if balance_result[:error]

    { data: format_balance(balance_result) }
  end

  def format_balance(balance_result)
    "R$ #{format('%.2f', balance_result[:data][:balance])}".gsub('.', ',')
  end

  def transfer(source_account_number:, destination_account_number:, ammount:)
    raise 'Invalid ammount, use a value bigger then zero' if ammount <= 0.0

    source_account = validate_account(source_account_number,
                                      'source account not found')
    destination_account = validate_account(destination_account_number,
                                           'destination account not found')

    validate_balance(source_account_number, ammount)

    persist_transactions(source_account.id, destination_account.id, ammount)

    { data: 'successful transfer' }
  rescue RuntimeError => e
    { error: true, data: e.message }
  end

  def validate_account(number, error_msg)
    account = Account.find_by(number: number)

    raise error_msg if account.nil?

    account
  end

  def validate_balance(source_account_number, ammount)
    balance = check_balance(account_number: source_account_number)
    if balance[:data][:balance] < ammount
      raise "your balance: #{format_balance(balance)} is insuficient"
    end
  end

  def create_transfer_operation(source_id:,
                                destination_id:,
                                ammount:,
                                operation_type:)

    ammount_value = operation_type.eql?('DEBIT') ? ammount * -1 : ammount
    owner_id = operation_type.eql?('DEBIT') ? source_id : destination_id

    {
      ammount: ammount_value,
      account_id: owner_id,
      operation_type: operation_type,
      source_account_id: source_id,
      destination_account_id: destination_id,
      operation: 'TRANSFER'
    }
  end

  def persist_transactions(source_id, destination_id, ammount)
    %w[CREDIT DEBIT].each do |op_type|
      operation = create_transfer_operation(source_id: source_id,
                                            destination_id: destination_id,
                                            ammount: ammount,
                                            operation_type: op_type)

      Transaction.create!(operation)
    end
  end
end
