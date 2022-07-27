class Publisher
    def initialize(queue_name)
        @connection = $bunny
        @connection.start
        @channel = @connection.create_channel
        @queue = @channel.queue(queue_name, durable: true)
    end

    def publish(message)
        @channel.default_exchange.publish(message, routing_key: @queue.name)
    end
end