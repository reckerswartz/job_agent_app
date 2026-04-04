require "rails_helper"

RSpec.describe "JobSources", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /job_sources" do
    it "renders the index page" do
      get job_sources_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Job Sources")
    end
  end

  describe "GET /job_sources/new" do
    it "renders the new form" do
      get new_job_source_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Add Job Source")
    end
  end

  describe "POST /job_sources" do
    it "creates a job source" do
      expect {
        post job_sources_path, params: {
          job_source: { name: "My LinkedIn", platform: "linkedin" }
        }
      }.to change(JobSource, :count).by(1)

      expect(response).to redirect_to(job_sources_path)
      expect(JobSource.last.base_url).to eq("https://www.linkedin.com/jobs/search/")
    end

    it "rejects invalid platform" do
      post job_sources_path, params: {
        job_source: { name: "Bad", platform: "invalid" }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /job_sources/:id/toggle" do
    let!(:source) { create(:job_source, user: user, enabled: true) }

    it "toggles enabled status" do
      patch toggle_job_source_path(source)
      expect(source.reload.enabled).to be false
      expect(response).to redirect_to(job_sources_path)
    end
  end

  describe "DELETE /job_sources/:id" do
    let!(:source) { create(:job_source, user: user) }

    it "destroys the source" do
      expect {
        delete job_source_path(source)
      }.to change(JobSource, :count).by(-1)
    end
  end
end
