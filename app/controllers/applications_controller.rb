class ApplicationsController < ActionController::API
    def index
        @applications = Application.all
        render json: @applications.to_json(:except => :id), status: :ok
    end

    def show
        @application = Application.find_by(token: params[:id])
        if @application
            render json: @application.to_json(:except => :id), status: :ok
        else 
            render status: :not_found
        end
    end

    def create
        @application = Application.new(application_params)
        if @application.save
            render json: { name: @application.name, token: @application.token }, status: :created
        else 
            render json: @application.errors, status: :unprocessable_entity
        end
    end

    def update
        @application = Application.find_by(token: params[:id])    
        if @application && @application.update(application_params)
            render json: { name: @application.name, token: @application.token }, status: :ok
        else 
            render status: :unprocessable_entity
        end
    end    

    private

    def application_params
      params.require(:application).permit(:name)
    end

end
