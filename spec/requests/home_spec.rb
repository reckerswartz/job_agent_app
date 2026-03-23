require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "renders the welcome heading" do
      get root_path
      expect(response.body).to include("Job Agent App")
    end
  end
end
