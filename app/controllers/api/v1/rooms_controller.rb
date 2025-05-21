class Api::V1::RoomsController < ApplicationController
  def index
    render json: Room.all
  end

  def create
    room = Room.create!(room_params)
    render json: room
  end


  def find_or_create
  user_ids = params[:user_ids].map(&:to_i).sort
  array_string = "ARRAY[#{user_ids.join(',')}]::bigint[]"

  room = Room.joins(:users)
             .group("rooms.id")
             .having("array_agg(users.id ORDER BY users.id) = #{array_string}")
             .first

  unless room
    usernames = User.where(id: user_ids).pluck(:username)
    room = Room.create!(name: usernames.join("_"))
    room.users << User.find(user_ids)
  end

  render json: room
end

  def room_params
    params.require(:room).permit(:name)
  end
end
