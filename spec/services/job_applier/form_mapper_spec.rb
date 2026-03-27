require "rails_helper"

RSpec.describe JobApplier::FormMapper do
  let(:user) { create(:user) }
  let(:profile) do
    create(:profile, user: user,
      headline: "Senior Rails Developer",
      contact_details: {
        "first_name" => "John",
        "surname" => "Doe",
        "email" => "john@example.com",
        "phone" => "+1-555-0123",
        "city" => "New York",
        "country" => "USA",
        "linkedin" => "https://linkedin.com/in/johndoe"
      })
  end

  let(:mapper) { described_class.new(profile) }

  describe "#to_form_data" do
    it "returns a hash of profile data" do
      data = mapper.to_form_data
      expect(data["first_name"]).to eq("John")
      expect(data["last_name"]).to eq("Doe")
      expect(data["email"]).to eq("john@example.com")
      expect(data["phone"]).to eq("+1-555-0123")
      expect(data["full_name"]).to eq("John Doe")
      expect(data["headline"]).to eq("Senior Rails Developer")
    end
  end

  describe "#map_fields" do
    it "maps known field names to profile values" do
      result = mapper.map_fields(%w[first_name email phone])
      expect(result["first_name"]).to eq("John")
      expect(result["email"]).to eq("john@example.com")
      expect(result["phone"]).to eq("+1-555-0123")
    end

    it "skips fields that cannot be mapped" do
      result = mapper.map_fields(%w[favorite_color])
      expect(result).to be_empty
    end
  end
end
