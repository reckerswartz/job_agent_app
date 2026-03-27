require "rails_helper"

RSpec.describe Intervention, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:interventionable) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:intervention_type) }
    it { is_expected.to validate_inclusion_of(:intervention_type).in_array(Intervention::TYPES) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Intervention::STATUSES) }
  end

  describe "#resolve!" do
    it "sets status to resolved with user input" do
      intervention = create(:intervention)
      intervention.resolve!({ "username" => "test@example.com" })
      expect(intervention.status).to eq("resolved")
      expect(intervention.user_input["username"]).to eq("test@example.com")
      expect(intervention.resolved_at).to be_present
    end
  end

  describe "#dismiss!" do
    it "sets status to dismissed" do
      intervention = create(:intervention)
      intervention.dismiss!
      expect(intervention.status).to eq("dismissed")
      expect(intervention.resolved_at).to be_present
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    it ".pending returns only pending interventions" do
      pending = create(:intervention, user: user)
      create(:intervention, :resolved, user: user)
      expect(Intervention.pending).to eq([pending])
    end

    it ".for_user scopes to user" do
      mine = create(:intervention, user: user)
      create(:intervention)
      expect(Intervention.for_user(user)).to eq([mine])
    end
  end

  describe "#parent_description" do
    it "describes a job application intervention" do
      intervention = create(:intervention)
      expect(intervention.parent_description).to include("Application:")
    end
  end

  describe "#type_label" do
    it "returns humanized type" do
      intervention = build(:intervention, intervention_type: "login_required")
      expect(intervention.type_label).to eq("Login required")
    end
  end
end
