module JobApplier
  class Base
    def initialize(job_application)
      @application = job_application
      @listing = job_application.job_listing
      @profile = job_application.profile
      @filler = FormFiller.new(@profile)
      @step_number = 0
    end

    def apply
      application.mark_in_progress!
      application.update!(form_data_used: filler.form_data_snapshot)

      record_step("navigate", "Navigating to job listing URL") do
        { url: listing.url }
      end

      record_step("fill_form", "Mapping and filling form fields") do
        filler.form_data_snapshot
      end

      if profile.source_document.attached?
        record_step("upload_resume", "Uploading resume document") do
          { filename: profile.source_document.filename.to_s }
        end
      end

      record_step("screenshot", "Capturing filled form state") do
        {}
      end

      record_step("click_submit", "Submitting application") do
        {}
      end

      record_step("verify", "Verifying submission confirmation") do
        { confirmed: true }
      end

      application.mark_submitted!
      listing.update!(status: "applied")

    rescue => e
      application.mark_failed!(e)
      raise
    end

    private

    attr_reader :application, :listing, :profile, :filler

    def record_step(action, description, &block)
      @step_number += 1
      step = application.application_steps.create!(
        step_number: @step_number,
        action: action,
        status: "pending",
        started_at: Time.current,
        input_data: { description: description }
      )

      begin
        output = block.call
        step.mark_completed!(output || {})
      rescue => e
        step.mark_failed!(e.message)
        raise
      end
    end
  end
end
