require "rails_helper"

RSpec.describe Profile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:profile_sections).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_inclusion_of(:source_mode).in_array(Profile::SOURCE_MODES) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Profile::STATUSES) }
  end

  describe "#contact_field" do
    it "returns the value for a given key" do
      profile = build(:profile, contact_details: { "first_name" => "John" })
      expect(profile.contact_field("first_name")).to eq("John")
    end

    it "returns empty string for missing key" do
      profile = build(:profile, contact_details: {})
      expect(profile.contact_field("phone")).to eq("")
    end
  end

  describe "#display_name" do
    it "returns first_name + surname when present" do
      profile = build(:profile, contact_details: { "first_name" => "John", "surname" => "Doe" })
      expect(profile.display_name).to eq("John Doe")
    end

    it "falls back to user display_name" do
      user = build(:user, email: "jane@example.com")
      profile = build(:profile, user: user, contact_details: {})
      expect(profile.display_name).to eq(user.display_name)
    end
  end

  describe "#complete?" do
    it "returns true when status is complete" do
      profile = build(:profile, :complete)
      expect(profile).to be_complete
    end

    it "returns false when status is draft" do
      profile = build(:profile, status: "draft")
      expect(profile).not_to be_complete
    end
  end

  describe "#mark_complete!" do
    it "updates status to complete" do
      profile = create(:profile, status: "draft")
      profile.mark_complete!
      expect(profile.reload.status).to eq("complete")
    end
  end

  describe "#completeness_percentage" do
    it "returns 0 for empty profile" do
      profile = create(:profile, headline: nil, summary: "", contact_details: {})
      expect(profile.completeness_percentage).to eq(0)
    end

    it "returns 20 for profile with contact details" do
      profile = create(:profile, headline: nil, summary: "", contact_details: { "first_name" => "John", "surname" => "Doe", "email" => "j@e.com" })
      expect(profile.completeness_percentage).to eq(20)
    end

    it "returns 50 for profile with contact + headline + summary" do
      profile = create(:profile, headline: "Dev", summary: "A summary", contact_details: { "first_name" => "John", "surname" => "Doe", "email" => "j@e.com" })
      expect(profile.completeness_percentage).to eq(50)
    end
  end

  describe "normalize_json_attributes" do
    it "strips whitespace from contact fields" do
      profile = create(:profile, contact_details: { "first_name" => "  John  " })
      expect(profile.contact_field("first_name")).to eq("John")
    end
  end
end
