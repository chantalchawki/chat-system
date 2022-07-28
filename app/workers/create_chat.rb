class CreateChat
    include Sneakers::Worker
    from_queue 'create_chat', durable: true

    def work(message)
      data = JSON.parse(message)
      Rails.logger.info "Create chat worker: #{data}"

      begin
        saved_chat = Chat.new({ number: data['number'], application_id: data['application']['id'] })
        if saved_chat.save
          new_count = $redis.incr("chats_count#{data['application']['token']}")
          $redis.hset("chats_count", { data['application']['token'] => new_count } )
          ack!
        end   
      rescue => exception
        Rails.logger.error "Error in create chat worker #{exception}"
      end
    end
end