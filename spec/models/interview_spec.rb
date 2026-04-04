require "rails_helper"

RSpec.describe Interview, type: :model do
  let(:interview) { build(:interview) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(interview).to be_valid
    end

    it "requires stage" do
      interview.stage = nil
      expect(interview).not_to be_valid
    end

    it "requires stage in STAGES list" do
      interview.stage = "invalid_stage"
      expect(interview).not_to be_valid
    end

    it "requires status in STATUSES list" do
      interview.status = "invalid_status"
      expect(interview).not_to be_valid
    end

    it "allows nil format" do
      interview.format = nil
      expect(interview).to be_valid
    end

    it "rejects invalid format" do
      interview.format = "telegram"
      expect(interview).not_to be_valid
    end

    it "allows nil rating" do
      interview.rating = nil
      expect(interview).to be_valid
    end

    it "rejects rating outside 1-5" do
      interview.rating = 6
      expect(interview).not_to be_valid
    end

    it "accepts rating in 1-5 range" do
      interview.rating = 3
      expect(interview).to be_valid
    end
  end

  describe "#completed?" do
    it "returns true when status is completed" do
      interview.status = "completed"
      expect(interview.completed?).to be true
    end

    it "returns false when status is scheduled" do
      interview.status = "scheduled"
      expect(interview.completed?).to be false
    end
  end

  describe "#stage_label" do
    it "humanizes the stage name" do
      interview.stage = "phone_screen"
      expect(interview.stage_label).to eq("Phone Screen")
    end

    it "titleizes multi-word stages" do
      interview.stage = "technical"
      expect(interview.stage_label).to eq("Technical")
    end
  end

  describe "#parsed_prep_questions" do
    it "returns empty array when no prep questions" do
      expect(interview.parsed_prep_questions).to eq([])
    end

    it "parses valid JSON array" do
      interview.prep_questions = '["Q1", "Q2"]'
      expect(interview.parsed_prep_questions).to eq([ "Q1", "Q2" ])
    end

    it "falls back to newline splitting on invalid JSON" do
      interview.prep_questions = "Question 1\nQuestion 2\n"
      expect(interview.parsed_prep_questions).to eq([ "Question 1", "Question 2" ])
    end
  end

  describe "scopes" do
    describe ".upcoming" do
      it "returns only scheduled interviews in the future" do
        upcoming = create(:interview, status: "scheduled", scheduled_at: 2.days.from_now)
        create(:interview, :completed)
        create(:interview, status: "scheduled", scheduled_at: 2.days.ago)

        expect(Interview.upcoming).to contain_exactly(upcoming)
      end
    end
  end
end
