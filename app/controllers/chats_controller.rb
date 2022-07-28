class ChatsController < ActionController::API
    before_action :get_application

    def index
        if @application
            @chats = Chat.where(application: @application.id)
            render json: @chats.to_json(:except => [:id, :application_id]), status: :ok
        else 
            render json: { message: 'Application token not found' }, status: :not_found
        end
    end

    def show
        if @application
            @chat = Chat.find_by(application: @application.id, number: params[:id])
            if @chat
                render json: @chat.to_json(:except => [:id, :application_id]), status: :ok
            else
                render json: { message: 'Chat not found' }, status: :not_found
            end
        else 
            render json: { message: 'Application token not found' }, status: :not_found
        end
    end

    def create
        begin
            if @application
                chat_number = $redis.incr(@application.token)
                chat = { number: chat_number, application: { id: @application.id, name: @application.name, token: @application.token } }
    
                published_message = JSON.generate(chat)
                publisher = Publisher.new('create_chat')
                publisher.publish(published_message)
    
                render json: { number: chat_number }, status: :created
            else
                render json: { message: 'Application token not found' }, status: :not_found
            end
        rescue => exception
            Rails.logger.error "Error creating chat: #{exception}"
            render json: { message: 'Error creating chat' }, status: :unprocessable_entity
        end
    end

    private

    def get_application
        @application = Application.find_by(token: params[:application_id])
    end
end
