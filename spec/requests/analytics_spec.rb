require "rails_helper"

RSpec.describe "Analytics", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /analytics" do
    it "renders the analytics page" do
      get analytics_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Analytics")
    end

    it "requires authentication" do
      sign_out user
      get analytics_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
