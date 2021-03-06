# frozen_string_literal: true

class AccountsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate

  before_action :set_account, only: %i[show update destroy]

  # GET /accounts
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # GET /accounts/1
  def show
    render json: @account
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
  end

  def check_balance
    operations = OperationsManager.new

    render json: operations.api_check_balance(account_number: params[:number])
  end

  def transfer
    operations = OperationsManager.new

    render json: operations
      .transfer(source_account_number: params[:source_account_number],
                destination_account_number: params[:destination_account_number],
                ammount: params[:ammount])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(:number,
                                    :source_account_number,
                                    :destination_account_number,
                                    :ammount)
  end

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      # Compare the tokens in a time-constant manner, to mitigate
      # timing attacks.

      user = User.find_by(token: token)
      user_token = user.nil? ? '' : user.token

      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token),
        ::Digest::SHA256.hexdigest(user_token)
      )
    end
  end
end
