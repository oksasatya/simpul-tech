class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :content, presence: true

  after_commit :broadcast_message, on: :create

  private

  def broadcast_message
    return if ENV["DISABLE_BROADCAST"] == "true"

    ChatChannel.broadcast_to(room, {
      user: user.username,
      content: content,
      created_at: created_at.strftime("%H:%M")
    })
  end
end
