class ApplicationController < ActionController::API
    include Pundit

    before_action :set_current_user
    after_action :set_api_version_header

    rescue_from Pundit::NotAuthorizedError, with: :forbidden_response
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_response
    rescue_from ActionController::ParameterMissing, with: :bad_request_response

    private

    def set_current_user
        Current.user = current_user if defined?(current_user)
    end

    def set_api_version_header
        response.headers["X-API-Version"] = "v1"
    end

    def forbidden_response(_exception = nil)
        render json: {
            error: "You are not authorized to perform this action",
            code: "FORBIDDEN"
        }, status: :forbidden
    end

    def not_found_response(exception)
        render json: {
            error: "#{exception.model || 'Resource'} not found",
            code: "NOT_FOUND"
        }, status: :not_found
    end

    def unprocessable_response(exception)
        render json: {
            error: exception.record.errors.full_messages,
            code: "VALIDATION_FAILED"
        }, status: :unprocessable_entity
    end

    def bad_request_response(exception)
        render json: {
            error: "Missing required parameter: #{exception.param}",
            code: "BAD_REQUEST"
        }, status: :bad_request
    end
end
