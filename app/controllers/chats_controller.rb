class ChatsController < ActionController::API
    before_action :get_application

    def index
        @chats = Chat.where(application: @application.id)
        render json: @chats.to_json(:except => [:id, :application_id]), status: :ok
    end

    def show
        @chat = Chat.find_by(application: @application.id, number: params[:id])
        if @chat
            render json: @chat.to_json(:except => [:id, :application_id]), status: :ok
        else
            render status: :not_found
        end
    end

    def create
        chat_number = $redis.incr(@application.token)
        chat = { number: chat_number, application: { id: @application.id, name: @application.name, token: @application.token } }

        published_message = JSON.generate(chat)
        publisher = Publisher.new('create_chat')
        publisher.publish(published_message)

        render json: { number: chat_number }, status: :created
    end

    private

    def get_application
        @application = Application.find_by(token: params[:application_id])
    end
end
