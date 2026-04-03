require "rails_helper"

RSpec.describe JobApplier::Base do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: source, url: "https://example.com/apply") }
  let(:profile) { create(:profile, user: user) }
  let(:application) { create(:job_application, job_listing: listing, profile: profile) }
  let(:sample_resume_path) do
    Rails.root.join("public/sample_resume_to_test/pankaj_senior_ruby_on_rails_developer_8_converted.pdf").to_s
  end
  let(:session) do
    instance_double(BrowserSession,
      navigate: "<html><body>mock page</body></html>",
      click: true,
      type_text: true,
      screenshot: "/tmp/mock_screenshot.png",
      wait_for_navigation: true,
      current_url: "https://example.com/confirmation",
      page_text: "Application submitted",
      login_required?: false,
      captcha_detected?: false,
      close: nil)
  end

  before do
    allow(BrowserSession).to receive(:new).and_return(session)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(sample_resume_path).and_return(true)
    allow(session).to receive(:upload_file).and_return(false)
    allow(session).to receive(:upload_file)
      .with("input[type='file']", sample_resume_path)
      .and_return(true)
  end

  describe "#apply" do
    it "uploads the predefined sample resume directly to a file input" do
      described_class.new(application).apply

      expect(session).to have_received(:upload_file)
        .with("input[type='file']", sample_resume_path)

      upload_step = application.reload.application_steps.find_by(action: "upload_resume")
      expect(upload_step).to be_present
      expect(upload_step.output_data).to include(
        "filename" => File.basename(sample_resume_path),
        "file_path" => sample_resume_path,
        "selector" => "input[type='file']",
        "uploaded" => true
      )
    end
  end
end
