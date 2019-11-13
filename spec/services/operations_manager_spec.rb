# frozen_string_literal: true

require 'rails_helper'

describe OperationsManager do
  subject { OperationsManager.new }

  describe '#check_balance(account_number)' do
    context 'account not found' do
      let(:invalid_number) { '1964' }

      it 'should call Account find_by with account_number' do
        expect(Account)
          .to receive(:find_by).with(number: '1964').and_call_original

        subject.check_balance(account_number: invalid_number)
      end

      it 'should returns hash with error key if account nil' do
        allow(Account).to receive(:find_by)
          .with(number: invalid_number).and_return(nil)

        expect(subject.check_balance(account_number: invalid_number))
          .to include(error: true)
      end

      it "should returns hash with key data 'account not found' if account nil" do
        allow(Account).to receive(:find_by)
          .with(number: invalid_number).and_return(nil)

        expect(subject.check_balance(account_number: invalid_number))
          .to include(data: 'account not found')
      end
    end

    context 'accounts exists' do
      let(:account_id) { 5 }

      before(:each) do
        acc_double = double
        allow(acc_double).to receive(:id).and_return(account_id)

        allow(Account).to receive(:find_by)
          .with(number: '1964').and_return(acc_double)
      end

      it 'should call Transaction.find_by(account_id:?) method' do
        expect(Transaction).to receive(:find_by)
          .with(account_id: account_id).and_return(nil).and_call_original

        subject.check_balance(account_number: '1964')
      end

      it 'if transactions nil returns data with key named balance=0.00' do
        allow(Transaction).to receive(:find_by)
          .with(account_id: account_id).and_return(nil)
        result = subject.check_balance(account_number: '1964')
        expect(result[:data])
          .to include(balance: 0.00)
      end

      it 'returns the sum of transaction quantities as balance' do
        transactions = [double, double]
        transactions.each do |tr|
          val = rand(100.0..1000.0).round(2)
          allow(tr).to receive(:ammount)
            .and_return(val)
        end

        allow(Transaction).to receive(:find_by)
          .with(account_id: account_id).and_return(transactions)

        expected = transactions[0].ammount + transactions[1].ammount

        result = subject.check_balance(account_number: '1964')

        expect(result[:data])
          .to include(balance: expected)
      end
    end
  end
end
