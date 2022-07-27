namespace :updater do
  desc 'Update chats and messages count'
  task update_counts: :environment do
    puts "Update counts STARTED #{Time.now}"
    
    chats = $redis.hgetall('chats_count')
    messages = $redis.hgetall('messages_count')

    chats.each do | key, value |
      application = Application.find_by(token: key)
      application.update(chats_count: value)
    end

    $redis.del('chats_count')

    messages.each do | key, value |
      key_part = key.split('_', -1)
      application = Application.find_by(token: key_part[0])
      chat = Chat.find_by(application: application.id, number: key_part[1])
      chat.update(messages_count: value)
    end

    $redis.del('messages_count')
    puts 'Update counts FINISHED'
  end
end
