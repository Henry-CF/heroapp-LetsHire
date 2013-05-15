class Api::V1::ApiController < ApplicationController
  respond_to :json

  def verify_current_user
    @current_user = User.find_by_authentication_token(params[:auth_token])
    render :json => { :message => 'Error verifying your auth token'}, :status => 401 and return unless @current_user
  end
end
