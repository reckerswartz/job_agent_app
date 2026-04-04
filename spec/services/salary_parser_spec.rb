require "rails_helper"

RSpec.describe SalaryParser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    it "returns nil for blank input" do
      expect(parser.parse(nil)).to be_nil
      expect(parser.parse("")).to be_nil
    end

    it "parses USD range with K suffix" do
      result = parser.parse("$120K - $160K")
      expect(result[:min]).to eq(120_000)
      expect(result[:max]).to eq(160_000)
      expect(result[:currency]).to eq("USD")
      expect(result[:period]).to eq("year")
    end

    it "parses plain number range" do
      result = parser.parse("120000-160000")
      expect(result[:min]).to eq(120_000)
      expect(result[:max]).to eq(160_000)
    end

    it "parses INR currency" do
      result = parser.parse("₹1500000 - ₹2500000")
      expect(result[:min]).to eq(1_500_000)
      expect(result[:max]).to eq(2_500_000)
      expect(result[:currency]).to eq("INR")
    end

    it "parses GBP" do
      result = parser.parse("£80K - £120K")
      expect(result[:min]).to eq(80_000)
      expect(result[:max]).to eq(120_000)
      expect(result[:currency]).to eq("GBP")
    end

    it "parses hourly rate and annualizes" do
      result = parser.parse("$50/hr")
      expect(result[:min]).to eq(104_000) # 50 * 2080
      expect(result[:period]).to eq("year")
    end

    it "handles single value (no range)" do
      result = parser.parse("$150K")
      expect(result[:min]).to eq(150_000)
      expect(result[:max]).to eq(150_000)
    end

    it "swaps min/max if reversed" do
      result = parser.parse("$200K - $100K")
      expect(result[:min]).to eq(100_000)
      expect(result[:max]).to eq(200_000)
    end

    it "defaults to USD when no currency symbol" do
      result = parser.parse("100K - 150K")
      expect(result[:currency]).to eq("USD")
    end

    it "parses EUR" do
      result = parser.parse("€60K - €90K")
      expect(result[:currency]).to eq("EUR")
      expect(result[:min]).to eq(60_000)
    end
  end
end
