# frozen_string_literal: true

class User < ApplicationRecord
  has_one :account

  before_create :generate_token

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
