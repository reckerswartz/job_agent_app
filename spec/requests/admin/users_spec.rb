require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, role: :admin) }
  before { sign_in admin }

  describe "GET /admin/users" do
    it "renders users list" do
      create(:user)
      get admin_users_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Users")
    end
  end

  describe "GET /admin/users/:id" do
    it "renders user detail" do
      user = create(:user)
      get admin_user_path(user)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.email)
    end
  end

  describe "PATCH /admin/users/:id/toggle_role" do
    it "toggles user role" do
      user = create(:user, role: :user)
      patch toggle_role_admin_user_path(user)
      expect(user.reload.role).to eq("admin")
      expect(response).to redirect_to(admin_user_path(user))
    end
  end

  context "as non-admin" do
    let(:regular_user) { create(:user, role: :user) }
    before { sign_in regular_user }

    it "denies access to users list" do
      get admin_users_path
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
