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

      it 'should call Transaction.where(account_id:?) method' do
        expect(Transaction).to receive(:where)
          .with(account_id: account_id).and_return(nil).and_call_original

        subject.check_balance(account_number: '1964')
      end

      it 'if transactions nil returns data with key named balance=0.00' do
        allow(Transaction).to receive(:where)
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

        allow(Transaction).to receive(:where)
          .with(account_id: account_id).and_return(transactions)

        expected = transactions[0].ammount + transactions[1].ammount

        result = subject.check_balance(account_number: '1964')

        expect(result[:data])
          .to include(balance: expected)
      end
    end
  end

  describe '#create_transfer_operation' do
    let(:source_id) { 1 }
    let(:destination_id) { 3 }
    let(:ammount) { 434.0 }

    context 'DEBIT operation type' do
      it 'should returns a negative ammount if DEBIT' do
        result = subject.create_transfer_operation(source_id: source_id,
                                                   destination_id: destination_id,
                                                   ammount: ammount,
                                                   operation_type: 'DEBIT')
        expect(result[:ammount]).to be < 0
      end

      it 'DEBITS must belong to the source account (account_id == source_account_id)' do
        result = subject.create_transfer_operation(source_id: source_id,
                                                   destination_id: destination_id,
                                                   ammount: ammount,
                                                   operation_type: 'DEBIT')

        expect(result[:account_id]).to eql(source_id)
      end

      it 'should have operation type equal to DEBIT' do
        result = subject.create_transfer_operation(source_id: source_id,
                                                   destination_id: destination_id,
                                                   ammount: ammount,
                                                   operation_type: 'DEBIT')

        expect(result[:operation_type]).to eql('DEBIT')
      end
    end

    context 'CREDIT operation type' do
      let(:credit_operation) { 'CREDIT' }
      it 'should returns a positive ammount if CREDIT' do
        result = subject.create_transfer_operation(source_id: source_id,
                                                   destination_id: destination_id,
                                                   ammount: ammount,
                                                   operation_type: credit_operation)
        expect(result[:ammount]).to be > 0
      end

      it 'CREDIT must belong to the destination account (account_id == destination_account_id)' do
        result = subject.create_transfer_operation(source_id: source_id,
                                                   destination_id: destination_id,
                                                   ammount: ammount,
                                                   operation_type: credit_operation)

        expect(result[:account_id]).to eql(destination_id)
      end

      it 'should have operation type equal to CREDIT' do
        result = subject.create_transfer_operation(source_id: source_id,
                                                   destination_id: destination_id,
                                                   ammount: ammount,
                                                   operation_type: credit_operation)

        expect(result[:operation_type]).to eql('CREDIT')
      end
    end

    it 'should have destination and source account ids in returned hash' do
      result = subject.create_transfer_operation(source_id: source_id,
                                                 destination_id: destination_id,
                                                 ammount: ammount,
                                                 operation_type: 'CREDIT')

      expect(result).to include(source_account_id: source_id,
                                destination_account_id: destination_id)
    end
    it 'should have operation equals TRANSFER in returned hash' do
      result = subject.create_transfer_operation(source_id: source_id,
                                                 destination_id: destination_id,
                                                 ammount: ammount,
                                                 operation_type: 'CREDIT')

      expect(result).to include(operation: 'TRANSFER')
    end
  end

  describe '#transfer' do
    let(:source) { '1231' }
    let(:destination) { '82321' }
    let(:ammount) { 150.0 }

    context 'Invalid Ammount Value' do
      it 'should raise error if ammount is minor or equal zero' do
        result = subject.transfer(source_account_number: source,
                                  destination_account_number: destination,
                                  ammount: 0.00)

        expect(result)
          .to include(error: true,
                      data: 'Invalid ammount, use a value bigger then zero')

        negative_result = subject.transfer(source_account_number: source,
                                           destination_account_number: destination,
                                           ammount: -3.00)

        expect(negative_result)
          .to include(error: true,
                      data: 'Invalid ammount, use a value bigger then zero')
      end
    end

    context 'Invalid Accounts' do
      it 'should returns error if source account not found' do
        allow(Account).to receive(:find_by)
          .with(number: source).and_return(nil)

        result = subject.transfer(source_account_number: source,
                                  destination_account_number: destination,
                                  ammount: ammount)

        expect(result).to include(error: true,
                                  data: 'source account not found')
      end

      it 'should returns error if destination account not found' do
        account_source = instance_double('Account', number: source)
        allow(Account).to receive(:find_by)
          .and_return(account_source, nil)

        result = subject.transfer(source_account_number: source,
                                  destination_account_number: destination,
                                  ammount: ammount)

        expect(result).to include(error: true,
                                  data: 'destination account not found')
      end
    end

    context 'Valid accounts' do
      before(:each) do
        source_account = instance_double('Account', number: source, id: 2)
        dest_account = instance_double('Account', number: destination, id: 3)

        allow(Account).to receive(:find_by)
          .and_return(source_account, dest_account)

        allow(subject).to receive(:check_balance)
          .with(account_number: source_account.number)
          .and_return(data: { balance: 200.00 })

        allow(Transaction)
          .to receive(:create!).and_return(true)
      end

      it 'should find account twice' do
        expect(Account)
          .to receive(:find_by).twice

        subject.transfer(source_account_number: source,
                         destination_account_number: destination,
                         ammount: ammount)
      end

      it 'should return error if insuficient balance' do
        insuficient_ammount = 1000.0
        result = subject.transfer(source_account_number: source,
                                  destination_account_number: destination,
                                  ammount: insuficient_ammount)

        expect(result)
          .to include(error: true,
                      data: 'your balance: R$ 200,00 is insuficient')
      end

      it 'should create operations calling Transaction.create twice' do
        expect(Transaction)
          .to receive(:create!).twice

        subject.transfer(source_account_number: source,
                         destination_account_number: destination,
                         ammount: ammount)
      end

      it 'should returns successful transfer' do
        result = subject.transfer(source_account_number: source,
                                  destination_account_number: destination,
                                  ammount: ammount)

        expect(result)
          .to include(data: 'successful transfer')
      end
    end
  end
end
