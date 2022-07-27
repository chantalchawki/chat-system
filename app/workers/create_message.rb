class CreateMessage
    include Sneakers::Worker
    from_queue 'create_message', durable: true

    def work(message)
      data = JSON.parse(message)
      puts data
      puts data['chat']['id']
      saved_message = Message.new({ number: data['number'], body: data['body'], chat_id: data['chat']['id'] })

      if saved_message.save
        new_count = $redis.incr("messages_count#{data['application']['token']}_#{data['chat']['number']}")
        $redis.hset("messages_count", { "#{data['application']['token']}_#{data['chat']['number']}" => new_count } )

        ack!
      end
    end
end