require "rails_helper"

RSpec.describe ProfileEntry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:profile_section) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
  end

  describe "auto-position" do
    it "assigns position 0 to first entry" do
      section = create(:profile_section)
      entry = create(:profile_entry, profile_section: section)
      expect(entry.position).to eq(0)
    end

    it "increments position for subsequent entries" do
      section = create(:profile_section)
      create(:profile_entry, profile_section: section)
      second = create(:profile_entry, profile_section: section)
      expect(second.position).to eq(1)
    end
  end

  describe "#highlights" do
    it "returns highlights array from content" do
      entry = build(:profile_entry, content: { "highlights" => [ "Led team", "Shipped product" ] })
      expect(entry.highlights).to eq([ "Led team", "Shipped product" ])
    end

    it "returns empty array when no highlights" do
      entry = build(:profile_entry, content: { "title" => "Dev" })
      expect(entry.highlights).to eq([])
    end
  end

  describe "normalize_content" do
    it "strips blank highlights" do
      entry = create(:profile_entry, content: { "highlights" => [ "Good", "", "  ", "Great" ] })
      expect(entry.content["highlights"]).to eq([ "Good", "Great" ])
    end
  end
end
