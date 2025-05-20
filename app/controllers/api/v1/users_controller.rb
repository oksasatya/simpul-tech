class Api::V1::UsersController < ApplicationController
  def index
    render json: User.all
  end

  def create
    user = User.find_or_create_by(username: params[:username])
    render json: user
  end
end
