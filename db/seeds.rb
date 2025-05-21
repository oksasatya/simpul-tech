# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Resetting database..."

Message.delete_all
RoomUser.delete_all
Room.delete_all
User.delete_all

puts "Resetting ID sequences..."
ActiveRecord::Base.connection.reset_pk_sequence!('messages')
ActiveRecord::Base.connection.reset_pk_sequence!('room_users')
ActiveRecord::Base.connection.reset_pk_sequence!('rooms')
ActiveRecord::Base.connection.reset_pk_sequence!('users')

andi = User.create!(id: 1, username: "andi")

friend_usernames = %w[budi citra dedi elisa ferdi]
friends = friend_usernames.map.with_index(2) do |name, i|
  User.create!(id: i, username: name)
end

puts "Creating rooms and dummy chat..."
friends.each_with_index do |friend, i|
  room = Room.create!(name: "#{andi.username}_#{friend.username}")
  room.users << andi
  room.users << friend

  base_time = Time.now.utc - (i + 1).hours

  5.times do |n|
    Message.create!(
      content: "Pesan ke-#{n + 1} dari andi ke #{friend.username}",
      user_id: andi.id,
      room_id: room.id,
      created_at: base_time + (n * 2).minutes
    )

    Message.create!(
      content: "Balasan ke-#{n + 1} dari #{friend.username} ke andi",
      user_id: friend.id,
      room_id: room.id,
      created_at: base_time + (n * 2).minutes + 1.minute
    )
  end
end

puts "Finished seeding database!"
