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
  end
end
