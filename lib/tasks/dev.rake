# frozen_string_literal: true

namespace :dev do
  desc 'Set development env data'
  task setup: :environment do
    puts 'Add user and accounts data to dev env'
    3.times do
      name = Faker::TvShows::GameOfThrones.character.split(' ')
      User.create!(
        name: name[0],
        last_name: name[1],
        email: Faker::Internet.email,
        account: Account.new(
          number: Faker::Bank.account_number
        )
      )
    end
    puts 'Add user and accounts data to dev env SUCCESS'

    puts 'generate deposits'
    Account.all.each do |account|
      Random.rand(5).times do
        Transaction.create!(
          source_account_id: nil,
          destination_account_id: account.id,
          ammount: rand(100.0..1000.0).round(2),
          operation: 'DEPOSIT',
          operation_type: 'CREDIT',
          account_id: account.id
        )
      end
    end

    puts 'generate deposits SUCCESS'
  end
end
