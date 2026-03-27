require "rails_helper"

RSpec.describe "JobSearchCriteria", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /job_search_criteria" do
    it "renders the index page" do
      get job_search_criteria_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Search Criteria")
    end
  end

  describe "GET /job_search_criteria/new" do
    it "renders the new form" do
      get new_job_search_criterium_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Search Criteria")
    end
  end

  describe "POST /job_search_criteria" do
    it "creates a search criteria" do
      expect {
        post job_search_criteria_path, params: {
          job_search_criteria: { name: "Rails NYC", keywords: "Ruby on Rails", location: "New York" }
        }
      }.to change(JobSearchCriteria, :count).by(1)

      expect(response).to redirect_to(job_search_criteria_path)
    end
  end

  describe "PATCH /job_search_criteria/:id/set_default" do
    let!(:criteria) { create(:job_search_criteria, user: user, is_default: false) }

    it "sets the criteria as default" do
      patch set_default_job_search_criterium_path(criteria)
      expect(criteria.reload.is_default).to be true
      expect(response).to redirect_to(job_search_criteria_path)
    end
  end

  describe "DELETE /job_search_criteria/:id" do
    let!(:criteria) { create(:job_search_criteria, user: user) }

    it "destroys the criteria" do
      expect {
        delete job_search_criterium_path(criteria)
      }.to change(JobSearchCriteria, :count).by(-1)
    end
  end
end
