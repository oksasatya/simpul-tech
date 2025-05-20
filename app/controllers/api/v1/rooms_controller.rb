class Api::V1::RoomsController < ApplicationController
  def index
    render json: Room.all
  end

  def create
    room = Room.create!(room_params)
    render json: room
  end

  private
  def room_params
    params.require(:room).permit(:name)
  end
end
