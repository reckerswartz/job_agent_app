require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:profiles).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    it { is_expected.to have_secure_password }
  end

  describe "password validation" do
    it "requires minimum 8 characters" do
      user = build(:user, password: "short", password_confirmation: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end
  end

  describe "email normalization" do
    it "strips and downcases email" do
      user = create(:user, email_address: "  Test@Example.COM  ")
      expect(user.email_address).to eq("test@example.com")
    end
  end

  describe "#display_name" do
    it "returns humanized part before @" do
      user = build(:user, email_address: "john@example.com")
      expect(user.display_name).to eq("John")
    end
  end

  describe "#initials" do
    it "returns first 2 initials" do
      user = build(:user, email_address: "pankaj@example.com")
      expect(user.initials).to eq("P")
    end
  end

  describe "role assignment" do
    it "does not override an explicitly set role" do
      user = create(:user, role: :admin)
      expect(user.role).to eq("admin")
    end

    it "assigns user role when other users exist" do
      create(:user)
      second = create(:user)
      expect(second.role).to eq("user")
    end
  end
end
