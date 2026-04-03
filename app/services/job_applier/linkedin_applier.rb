module JobApplier
  class LinkedinApplier
    FORM_PAGE_LIMIT = 5

    def initialize(job_application)
      @application = job_application
      @listing = job_application.job_listing
      @profile = job_application.profile
      @step_num = 0
    end

    def apply
      return unless listing.easy_apply?

      @session = BrowserSession.new(headless: false)
      application.mark_in_progress!

      log_step("navigate", "Opening job page: #{listing.url}") do
        html = @session.navigate(listing.url, wait_until: "domcontentloaded")
        raise "Page load failed" if html.nil?
        sleep(2)
        { url: listing.url }
      end

      if @session.login_required?
        flag_intervention("login_required", "LinkedIn login needed for Easy Apply")
        application.mark_needs_intervention!("LinkedIn login required")
        return
      end

      log_step("open_easy_apply", "Clicking Easy Apply") do
        opened = trigger_easy_apply_modal
        raise "Easy Apply button not found" unless opened
        sleep(2)
        { opened: true }
      end

      FORM_PAGE_LIMIT.times do |pg|
        log_step("form_page_#{pg + 1}", "Processing form page #{pg + 1}") do
          populate_visible_fields
          attempt_resume_upload
          sleep(1)
          { page: pg + 1 }
        end

        if submit_visible?
          log_step("submit_application", "Submitting") do
            press_submit
            sleep(3)
            { submitted: true }
          end
          break
        elsif next_visible?
          log_step("advance_page", "Going to next page") do
            press_next
            sleep(2)
            { advanced: true }
          end
        else
          break
        end
      end

      log_step("confirm", "Checking result") do
        confirmed = check_success
        { confirmed: confirmed, final_url: @session.current_url }
      end

      application.mark_submitted!
      listing.update!(status: "applied")

      if listing.user&.notify?("email_application_status")
        NotificationMailer.application_status(listing.user, application).deliver_later
      end

    rescue => e
      application.mark_failed!(e)
      Rails.logger.error("[LinkedinApplier] Error: #{e.message}")
    ensure
      @session&.close
    end

    private

    attr_reader :application, :listing, :profile

    def trigger_easy_apply_modal
      @session.evaluate(<<~JAVASCRIPT)
        (() => {
          const candidates = document.querySelectorAll('button');
          for (const b of candidates) {
            const txt = b.textContent.trim().toLowerCase();
            if (txt.includes('easy apply')) { b.click(); return true; }
          }
          return false;
        })()
      JAVASCRIPT
    end

    def populate_visible_fields
      field_values = gather_profile_data
      @session.evaluate(populate_fields_js(field_values))
    end

    def populate_fields_js(data)
      json = data.to_json
      <<~JAVASCRIPT
        (() => {
          const vals = #{json};
          const inputs = document.querySelectorAll(
            'input[type="text"], input[type="email"], input[type="tel"], input[type="url"], input[type="number"]'
          );
          inputs.forEach(inp => {
            if (inp.value && inp.value.trim().length > 0) return;
            const ctx = [
              inp.closest('div')?.querySelector('label')?.textContent || '',
              inp.name || '', inp.id || '', inp.placeholder || ''
            ].join(' ').toLowerCase();

            let v = null;
            if (ctx.match(/first.?name/)) v = vals.first_name;
            else if (ctx.match(/last.?name|surname/)) v = vals.last_name;
            else if (ctx.match(/email/)) v = vals.email;
            else if (ctx.match(/phone|mobile|cell/)) v = vals.phone;
            else if (ctx.match(/city|location/)) v = vals.city;
            else if (ctx.match(/linkedin/)) v = vals.linkedin;
            else if (ctx.match(/website|portfolio/)) v = vals.website;
            else if (ctx.match(/title|headline|position/)) v = vals.headline;
            else if (ctx.match(/experience|years/)) v = vals.years_exp;

            if (v) {
              const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
              setter.call(inp, v);
              inp.dispatchEvent(new Event('input', {bubbles: true}));
              inp.dispatchEvent(new Event('change', {bubbles: true}));
            }
          });

          document.querySelectorAll('textarea').forEach(ta => {
            if (ta.value && ta.value.trim().length > 0) return;
            const setter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
            setter.call(ta, vals.summary || '');
            ta.dispatchEvent(new Event('input', {bubbles: true}));
          });

          document.querySelectorAll('select[required]').forEach(sel => {
            if (!sel.value || sel.selectedIndex <= 0) {
              if (sel.options.length > 1) {
                sel.selectedIndex = 1;
                sel.dispatchEvent(new Event('change', {bubbles: true}));
              }
            }
          });

          const groups = {};
          document.querySelectorAll('input[type="radio"]').forEach(r => {
            if (!groups[r.name]) groups[r.name] = [];
            groups[r.name].push(r);
          });
          Object.values(groups).forEach(g => {
            if (!g.some(r => r.checked) && g.length > 0) g[0].click();
          });

          return true;
        })()
      JAVASCRIPT
    end

    def attempt_resume_upload
      has_file_input = @session.evaluate("!!document.querySelector('input[type=\"file\"]')")
      return unless has_file_input && profile.source_document.attached?

      blob = profile.source_document.blob
      tmp = Rails.root.join("tmp", "resume_upload_#{profile.id}#{File.extname(blob.filename.to_s)}").to_s
      unless File.exist?(tmp)
        blob.open { |f| FileUtils.cp(f.path, tmp) }
      end
      @session.upload_file('input[type="file"]', tmp)
      sleep(1)
      Rails.logger.info("[LinkedinApplier] Uploaded resume: #{blob.filename}")
    rescue => e
      Rails.logger.warn("[LinkedinApplier] Resume upload issue: #{e.message}")
    end

    def submit_visible?
      @session.evaluate(<<~JAVASCRIPT) || false
        (() => {
          const btns = document.querySelectorAll('button');
          for (const b of btns) {
            const t = b.textContent.trim().toLowerCase();
            if (t.includes('submit application') || t === 'submit') return true;
          }
          return false;
        })()
      JAVASCRIPT
    end

    def next_visible?
      @session.evaluate(<<~JAVASCRIPT) || false
        (() => {
          const btns = document.querySelectorAll('button');
          for (const b of btns) {
            const t = b.textContent.trim().toLowerCase();
            if (t === 'next' || t === 'continue' || t === 'review') return true;
          }
          return false;
        })()
      JAVASCRIPT
    end

    def press_submit
      @session.evaluate(<<~JAVASCRIPT)
        (() => {
          const btns = document.querySelectorAll('button');
          for (const b of btns) {
            const t = b.textContent.trim().toLowerCase();
            if (t.includes('submit application') || t === 'submit') { b.click(); return true; }
          }
          return false;
        })()
      JAVASCRIPT
    end

    def press_next
      @session.evaluate(<<~JAVASCRIPT)
        (() => {
          const btns = document.querySelectorAll('button');
          for (const b of btns) {
            const t = b.textContent.trim().toLowerCase();
            if (t === 'next' || t === 'continue' || t === 'review') { b.click(); return true; }
          }
          return false;
        })()
      JAVASCRIPT
    end

    def check_success
      txt = @session.page_text.downcase
      txt.include?("application submitted") || txt.include?("application was sent") ||
        txt.include?("you applied") || txt.include?("application has been submitted")
    end

    def gather_profile_data
      work_section = profile.profile_sections.find_by(section_type: "work_experience")
      years = work_section ? (work_section.profile_entries.count * 2).to_s : ""

      {
        first_name: profile.contact_field("first_name"),
        last_name: profile.contact_field("surname"),
        email: profile.contact_field("email"),
        phone: profile.contact_field("phone"),
        city: profile.contact_field("city"),
        linkedin: profile.contact_field("linkedin"),
        website: profile.contact_field("website"),
        headline: profile.headline,
        summary: profile.summary.to_s.truncate(500),
        years_exp: years
      }
    end

    def log_step(action, desc, &block)
      @step_num += 1
      step = application.application_steps.create!(
        step_number: @step_num, action: action, status: "pending",
        started_at: Time.current, input_data: { description: desc }
      )
      begin
        result = yield
        step.mark_completed!(result || {})
      rescue => e
        step.mark_failed!(e.message)
        raise
      end
    end

    def flag_intervention(type, reason)
      InterventionCreator.create_for(
        application, type: type,
        context: { page_url: @session&.current_url, reason: reason,
                   listing_title: listing.title, listing_company: listing.company },
        user: listing.user
      )
    end
  end
end
