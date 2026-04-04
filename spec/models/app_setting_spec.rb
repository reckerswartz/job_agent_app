require "rails_helper"

RSpec.describe AppSetting, type: :model do
  describe "validations" do
    it "requires key" do
      setting = AppSetting.new(key: nil)
      expect(setting).not_to be_valid
      expect(setting.errors[:key]).to include("can't be blank")
    end

    it "requires unique key" do
      AppSetting.create!(key: "test_key", encrypted_value: "val")
      duplicate = AppSetting.new(key: "test_key")
      expect(duplicate).not_to be_valid
    end
  end

  describe ".set and .get" do
    it "stores and retrieves a value" do
      AppSetting.set("nvidia_api_key", "test-api-key-123")
      expect(AppSetting.get("nvidia_api_key")).to eq("test-api-key-123")
    end

    it "updates existing value on re-set" do
      AppSetting.set("nvidia_api_key", "old-value")
      AppSetting.set("nvidia_api_key", "new-value")
      expect(AppSetting.get("nvidia_api_key")).to eq("new-value")
      expect(AppSetting.where(key: "nvidia_api_key").count).to eq(1)
    end

    it "returns nil for unset key without ENV" do
      expect(AppSetting.get("nonexistent_key")).to be_nil
    end
  end

  describe "#masked_value" do
    it "masks long values showing only last 4 chars" do
      setting = AppSetting.new(encrypted_value: "abcdefghijklmnop")
      expect(setting.masked_value).to end_with("mnop")
      expect(setting.masked_value).to start_with("*")
    end

    it "returns **** for short values" do
      setting = AppSetting.new(encrypted_value: "short")
      expect(setting.masked_value).to eq("****")
    end

    it "returns nil for blank value" do
      setting = AppSetting.new(encrypted_value: nil)
      expect(setting.masked_value).to be_nil
    end
  end
end
