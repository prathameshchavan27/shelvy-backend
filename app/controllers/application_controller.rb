class ApplicationController < ActionController::API
    include Pundit
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    before_action :set_current_user

    def set_current_user
        Current.user = current_user if defined?(current_user)
    end

    private

    def user_not_authorized
        render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
end
