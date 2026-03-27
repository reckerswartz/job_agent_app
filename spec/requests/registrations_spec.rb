require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /sign_up" do
    it "renders the sign up form" do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Create your account")
    end
  end

  describe "POST /sign_up" do
    context "with valid params" do
      it "creates a user and redirects to dashboard" do
        expect {
          post user_registration_path, params: {
            user: { email: "new@example.com", password: "password123", password_confirmation: "password123" }
          }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid params" do
      it "does not create a user with short password" do
        expect {
          post user_registration_path, params: {
            user: { email: "new@example.com", password: "short", password_confirmation: "short" }
          }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a user with mismatched passwords" do
        expect {
          post user_registration_path, params: {
            user: { email: "new@example.com", password: "password123", password_confirmation: "different" }
          }
        }.not_to change(User, :count)
      end
    end
  end
end
