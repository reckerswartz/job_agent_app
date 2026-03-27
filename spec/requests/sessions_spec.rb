require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /sign_in" do
    it "renders the sign in form" do
      get sign_in_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Welcome back")
    end
  end

  describe "POST /sign_in" do
    context "with valid credentials" do
      it "signs in and redirects to dashboard" do
        post sign_in_path, params: { email_address: user.email_address, password: "password123" }
        expect(response).to redirect_to(dashboard_path)
      end

      it "creates a session record" do
        expect {
          post sign_in_path, params: { email_address: user.email_address, password: "password123" }
        }.to change(Session, :count).by(1)
      end
    end

    context "with invalid credentials" do
      it "re-renders sign in with error" do
        post sign_in_path, params: { email_address: user.email_address, password: "wrongpassword" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email or password")
      end
    end
  end

  describe "DELETE /sign_out" do
    it "signs out and redirects to root" do
      sign_in_as(user)
      delete sign_out_path
      expect(response).to redirect_to(root_path)
    end
  end
end
