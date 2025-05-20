class Api::V1::MessagesController < ApplicationController
  def create
    message = Message.create!(message_params)
    render json: {
      id: message.id,
      user: message.user.username,
      content: message.content,
      room_id: message.room_id,
      created_at: message.created_at.strftime("%H:%M"),
    }
  end

  def index
    messages = Message.includes(:user).where(room_id: params[:room_id]).order(created_at: :asc)
    render json: messages.map { |msg| format_message(msg) }
  end

  private

  def message_params
    params.require(:message).permit(:content, :room_id, :user_id)
  end

  def format_message(msg)
    {
      id: msg.id,
      user: msg.user.username,
      content: msg.content,
      time: msg.created_at.strftime("%H:%M"),
    }
  end
end
