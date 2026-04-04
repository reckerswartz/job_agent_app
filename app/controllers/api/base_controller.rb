module Api
  class BaseController < ActionController::API
    before_action :authenticate_api_token!

    private

    def authenticate_api_token!
      token = request.headers["Authorization"]&.remove("Bearer ")
      @current_user = User.find_by(api_token: token) if token.present?
      render json: { error: "Unauthorized. Provide a valid Bearer token." }, status: :unauthorized unless @current_user
    end

    def current_user
      @current_user
    end

    def paginate(scope, per: 20)
      page = [ params.fetch(:page, 1).to_i, 1 ].max
      per = [ [ params.fetch(:per_page, per).to_i, 1 ].max, 100 ].min
      total = scope.count
      records = scope.offset((page - 1) * per).limit(per)
      meta = { page: page, per_page: per, total: total, total_pages: (total.to_f / per).ceil }
      [ records, meta ]
    end

    def render_json(data, meta: nil, status: :ok)
      body = { data: data }
      body[:meta] = meta if meta
      render json: body, status: status
    end
  end
end
