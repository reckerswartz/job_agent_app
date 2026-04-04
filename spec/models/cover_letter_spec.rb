require "rails_helper"

RSpec.describe CoverLetter, type: :model do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: source) }
  let(:profile) { create(:profile, user: user) }

  it "validates content presence" do
    cl = CoverLetter.new(job_listing: listing, profile: profile, content: nil)
    expect(cl).not_to be_valid
    expect(cl.errors[:content]).to include("can't be blank")
  end

  it "validates tone inclusion" do
    cl = CoverLetter.new(job_listing: listing, profile: profile, content: "Hello", tone: "invalid")
    expect(cl).not_to be_valid
  end

  it "creates a valid cover letter" do
    cl = CoverLetter.create!(job_listing: listing, profile: profile, content: "Dear Hiring Manager...", tone: "professional", status: "draft")
    expect(cl).to be_persisted
  end

  it "belongs to job_listing" do
    cl = CoverLetter.create!(job_listing: listing, profile: profile, content: "Test")
    expect(cl.job_listing).to eq(listing)
  end
end
