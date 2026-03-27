module JobApplier
  class Base
    def initialize(job_application)
      @application = job_application
      @listing = job_application.job_listing
      @profile = job_application.profile
      @filler = FormFiller.new(@profile)
      @step_number = 0
      @session = nil
    end

    def apply
      @session = BrowserSession.new
      application.mark_in_progress!
      application.update!(form_data_used: filler.form_data_snapshot)

      record_step("navigate", "Navigating to #{listing.url}") do
        html = @session.navigate(listing.url)
        raise "Failed to load page" if html.nil?
        { url: listing.url, loaded: true }
      end

      if @session.login_required?
        create_intervention!("login_required", "Login required to apply")
        application.mark_needs_intervention!("Login required")
        return
      end

      if @session.captcha_detected?
        create_intervention!("captcha", "CAPTCHA detected on application page")
        application.mark_needs_intervention!("CAPTCHA detected")
        return
      end

      record_step("fill_form", "Identifying and filling form fields") do
        form_data = filler.form_data_snapshot
        fill_detected_fields(form_data)
        form_data
      end

      if profile.source_document.attached?
        record_step("upload_resume", "Uploading resume document") do
          { filename: profile.source_document.filename.to_s, note: "Resume upload attempted" }
        end
      end

      record_step("screenshot", "Capturing filled form state") do
        path = @session.screenshot
        { screenshot_path: path }
      end

      record_step("click_submit", "Submitting application") do
        submitted = try_submit
        { submitted: submitted }
      end

      record_step("verify", "Verifying submission") do
        @session.wait_for_navigation
        url = @session.current_url
        { final_url: url, page_text_preview: @session.page_text.to_s.truncate(500) }
      end

      application.mark_submitted!
      listing.update!(status: "applied")

      if listing.user&.notify?("email_application_status")
        NotificationMailer.application_status(listing.user, application).deliver_later
      end

    rescue => e
      application.mark_failed!(e)
      if listing.user&.notify?("email_application_status")
        NotificationMailer.application_status(listing.user, application).deliver_later
      end
      raise
    ensure
      @session&.close
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

    def fill_detected_fields(form_data)
      form_data.each do |field_name, value|
        next if value.blank?

        selectors = [
          "input[name*='#{field_name}']",
          "input[id*='#{field_name}']",
          "input[placeholder*='#{field_name}']",
          "textarea[name*='#{field_name}']"
        ]

        selectors.each do |selector|
          if @session.type_text(selector, value)
            break
          end
        end
      end
    end

    def try_submit
      submit_selectors = [
        "button[type='submit']",
        "input[type='submit']",
        "button:has-text('Apply')",
        "button:has-text('Submit')",
        "button:has-text('Send')",
        "a:has-text('Apply')"
      ]

      submit_selectors.each do |selector|
        if @session.click(selector)
          return true
        end
      end

      false
    end

    def create_intervention!(type, reason)
      screenshot_path = @session&.screenshot
      InterventionCreator.create_for(
        application,
        type: type,
        context: {
          page_url: @session&.current_url,
          reason: reason,
          listing_title: listing.title,
          listing_company: listing.company
        },
        user: listing.user
      )
    end
  end
end
