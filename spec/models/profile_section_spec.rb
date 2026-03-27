require "rails_helper"

RSpec.describe ProfileSection, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:profile) }
    it { is_expected.to have_many(:profile_entries).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:section_type) }
    it { is_expected.to validate_inclusion_of(:section_type).in_array(ProfileSection::SECTION_TYPES) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "auto-position" do
    it "assigns position 0 to first section" do
      profile = create(:profile)
      section = create(:profile_section, profile: profile)
      expect(section.position).to eq(0)
    end

    it "increments position for subsequent sections" do
      profile = create(:profile)
      create(:profile_section, profile: profile, section_type: "work_experience")
      second = create(:profile_section, profile: profile, section_type: "education")
      expect(second.position).to eq(1)
    end
  end

  describe "default_title" do
    it "assigns title from section_type if blank" do
      section = build(:profile_section, section_type: "work_experience", title: "")
      section.valid?
      expect(section.title).to eq("Work Experience")
    end

    it "does not override existing title" do
      section = build(:profile_section, section_type: "skills", title: "Technical Skills")
      section.valid?
      expect(section.title).to eq("Technical Skills")
    end
  end
end
