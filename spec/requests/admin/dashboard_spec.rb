require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    context "as admin" do
      let(:admin) { create(:user, role: :admin) }
      before { sign_in admin }

      it "renders the admin dashboard" do
        get admin_root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Admin Dashboard")
      end
    end

    context "as regular user" do
      let(:user) { create(:user, role: :user) }
      before { sign_in user }

      it "redirects to dashboard with access denied" do
        get admin_root_path
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "unauthenticated" do
      it "redirects to sign in" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
