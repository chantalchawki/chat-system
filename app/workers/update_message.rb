class UpdateMessage
    include Sneakers::Worker
    from_queue 'update_message', durable: true

    def work(message)
      data = JSON.parse(message)
      Rails.logger.info "Update message worker: #{data}"
      begin
        update_message = Message.find_by(chat: data['chat']['id'], number: data['number'])
        if update_message && update_message.update(body: data['body'])
          ack!
        end
      rescue => exception
        Rails.logger.error "Error in update message worker #{exception}"
      end
    end
end