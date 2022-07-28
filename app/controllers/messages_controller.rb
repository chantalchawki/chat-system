class MessagesController < ActionController::API
    before_action :get_application, :get_chat

    def index
        if @chat
            if params.has_key?(:query)
                result = Message.search(params[:query], @chat.id)
                render json: result.map(&:_source).to_json(:except => [:chat_id]), status: :ok
            else
                @messages = Message.where(chat: @chat.id)
                render json: @messages.to_json(:except => [:id, :chat_id]), status: :ok
            end
        else
            render json: { message: 'Application token or chat number not found' }, status: :not_found
        end
    end

    def show
        if @chat
            @message = Message.find_by(chat: @chat.id, number: params[:id])
            if @message
                render json: @message.to_json(:except => [:id, :chat_id]), status: :ok
            else
                render json: { message: 'Message not found' }, status: :not_found
            end
        else
            render json: { message: 'Application token or chat number not found' }, status: :not_found
        end
    end

    def create
        begin
            if @chat && @application
                message_number = $redis.incr("#{@application.token}-#{@chat.number}")
                message_object = { 
                    number: message_number, body: message_params["body"],  
                    application: { id: @application.id, name: @application.name, token: @application.token }, 
                    chat: { id: @chat.id,  number: @chat.number } 
                }
    
                published_message = JSON.generate(message_object)
                publisher = Publisher.new('create_message')
                publisher.publish(published_message)
                render json: { number: message_number, body: message_params["body"] }, status: :created
            else
                render json: { message: 'Application token or chat number not found' }, status: :not_found
            end
        rescue => exception
            Rails.logger.error "Error creating message #{exception}"
            render json: { message: 'Error creating message' }, status: :unprocessable_entity
        end
    end

    def update
        begin
            if @chat && @application
                message_object = { 
                    number: params[:id].to_i, body: message_params["body"],  
                    application: { id: @application.id, name: @application.name, token: @application.token }, 
                    chat: { id: @chat.id,  number: @chat.number } 
                }
    
                published_message = JSON.generate(message_object)
                publisher = Publisher.new('update_message')
                publisher.publish(published_message)
                render json: { number: params[:id].to_i, body: message_params["body"] }, status: :ok
            else
                render json: { message: 'Application token or chat number not found' }, status: :not_found
            end
        rescue => exception
            Rails.logger.error "Error updating message #{exception}"
            render json: { message: 'Error updating message' }, status: :unprocessable_entity
        end
    end

    private

    def get_application
        @application = Application.find_by(token: params[:application_id])
    end

    def get_chat
        if @application
            @chat = Chat.find_by(number: params[:chat_id], application: @application.id)
        else
            render json: { message: 'Application token not found'}, status: :not_found
        end
    end

    def message_params
        params.require(:message).permit(:body)
    end
end
