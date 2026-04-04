require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /sign_in" do
    it "renders the sign in form" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Welcome back")
    end
  end

  describe "POST /sign_in" do
    context "with valid credentials" do
      it "signs in and redirects to dashboard" do
        post user_session_path, params: { user: { email: user.email, password: "password123" } }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid credentials" do
      it "re-renders sign in with error" do
        post user_session_path, params: { user: { email: user.email, password: "wrongpassword" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /sign_out" do
    it "signs out and redirects to root" do
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end
