require "rails_helper"

RSpec.describe BadgeHelper, type: :helper do
  describe "#status_badge" do
    it "renders a success badge for completed scan" do
      result = helper.status_badge("completed", :scan)
      expect(result).to include('class="badge bg-success"')
      expect(result).to include("Completed")
    end

    it "renders a danger badge for failed application" do
      result = helper.status_badge("failed", :application)
      expect(result).to include('class="badge bg-danger"')
      expect(result).to include("Failed")
    end

    it "renders a warning badge for pending intervention" do
      result = helper.status_badge("pending", :intervention)
      expect(result).to include('class="badge bg-warning"')
    end

    it "renders secondary badge for unknown value" do
      result = helper.status_badge("unknown_status", :listing)
      expect(result).to include('class="badge bg-secondary"')
    end
  end

  describe "#badge_color" do
    it "returns correct color for listing statuses" do
      expect(helper.badge_color("new", :listing)).to eq("info")
      expect(helper.badge_color("applied", :listing)).to eq("success")
      expect(helper.badge_color("rejected", :listing)).to eq("danger")
    end

    it "returns correct color for model types" do
      expect(helper.badge_color("text", :model_type)).to eq("primary")
      expect(helper.badge_color("vision", :model_type)).to eq("warning")
      expect(helper.badge_color("multimodal", :model_type)).to eq("info")
    end

    it "returns correct color for user roles" do
      expect(helper.badge_color("admin", :role)).to eq("danger")
      expect(helper.badge_color("user", :role)).to eq("secondary")
    end

    it "returns correct color for verification statuses" do
      expect(helper.badge_color("ok", :verification)).to eq("success")
      expect(helper.badge_color("failed", :verification)).to eq("danger")
      expect(helper.badge_color("timeout", :verification)).to eq("warning")
    end

    it "returns secondary for unknown context" do
      expect(helper.badge_color("anything", :nonexistent)).to eq("secondary")
    end
  end
end
