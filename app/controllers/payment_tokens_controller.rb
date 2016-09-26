class PaymentTokensController < ApplicationController

  before_filter :authenticate_user_json
  def show
    result = authed_user.get_braintree_token
    if result[:status] == 'success'
      client_token = Braintree::ClientToken.generate(
        customer_id: result[:token]
      )
      if client_token.present?
        render json: {status: 'success', token: client_token, status: :ok}
      else
        render json: {status: 'failed', error: 'Token is not present for this id', status: :not_found}
      end
    else
      render json: {status: 'failed', error: token.error}
    end
  end
end
