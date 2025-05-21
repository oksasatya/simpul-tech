class Api::V1::UsersController < ApplicationController
  def index
    render json: User.all
  end

  def create
    user = User.find_or_create_by(username: params[:username])
    render json: user
  end


  def chat_partners
    current_user_id = params[:user_id].to_i

    users = User.where.not(id: current_user_id).map do |user|
      room = Room.joins(:users)
                 .group("rooms.id")
                 .having("array_agg(users.id ORDER BY users.id) = ARRAY[#{[current_user_id, user.id].sort.join(',')}]::bigint[]")
                 .first

      last_message = room&.messages&.order(created_at: :desc)&.first

      {
        id: user.id,
        username: user.username,
        last_message: last_message ? {
          content: last_message.content,
          time: last_message.created_at.strftime("%H:%M")
        } : nil
      }
    end

    render json: users
  end
end

