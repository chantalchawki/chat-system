class CreateMessage
    include Sneakers::Worker
    from_queue 'create_message', durable: true

    def work(message)
      data = JSON.parse(message)
      Rails.logger.info "Create message worker: #{data}"

      begin
        saved_message = Message.new({ number: data['number'], body: data['body'], chat_id: data['chat']['id'] })
        if saved_message.save
          new_count = $redis.incr("messages_count#{data['application']['token']}_#{data['chat']['number']}")
          $redis.hset("messages_count", { "#{data['application']['token']}_#{data['chat']['number']}" => new_count } )
          ack!
        end
        
      rescue => exception
        Rails.logger.error "Error in message chat worker #{exception}"
      end
    end
end