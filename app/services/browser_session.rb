require "playwright"

class BrowserSession
  LOGIN_INDICATORS = %w[/login /signin /auth /sign-in /log-in].freeze
  CAPTCHA_INDICATORS = [ "captcha", "verify you're human", "i'm not a robot", "recaptcha", "hcaptcha" ].freeze

  attr_reader :page, :browser, :playwright

  def initialize(headless: true)
    @playwright = Playwright.create(playwright_cli_executable_path: find_playwright_cli)
    launch_options = { headless: headless }
    # Use system Chrome if Playwright's bundled browser is not available
    chrome_path = find_chrome_executable
    launch_options[:executablePath] = chrome_path if chrome_path
    @browser = @playwright.chromium.launch(**launch_options)
    @context = @browser.new_context(
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      viewport: { width: 1280, height: 800 }
    )
    @page = @context.new_page
  end

  def navigate(url, wait_until: "domcontentloaded")
    page.goto(url, waitUntil: wait_until, timeout: 30_000)
    sleep(1) # allow dynamic content to settle
    page.content
  rescue Playwright::TimeoutError => e
    Rails.logger.warn("[BrowserSession] Navigation timeout for #{url}: #{e.message}")
    nil
  end

  def evaluate(js_code)
    page.evaluate(js_code)
  rescue => e
    Rails.logger.error("[BrowserSession] JS evaluation error: #{e.message}")
    nil
  end

  def snapshot
    page.content
  end

  def click(selector)
    page.click(selector, timeout: 10_000)
  rescue Playwright::TimeoutError
    Rails.logger.warn("[BrowserSession] Click timeout for selector: #{selector}")
    false
  end

  def type_text(selector, text)
    page.fill(selector, text, timeout: 10_000)
  rescue Playwright::TimeoutError
    Rails.logger.warn("[BrowserSession] Type timeout for selector: #{selector}")
    false
  end

  def screenshot(path = nil)
    path ||= Rails.root.join("tmp", "screenshots", "browser_#{Time.current.to_i}.png").to_s
    FileUtils.mkdir_p(File.dirname(path))
    page.screenshot(path: path, fullPage: true)
    path
  end

  def upload_file(selector, file_path)
    page.set_input_files(selector, file_path, timeout: 10_000)
    true
  rescue => e
    Rails.logger.warn("[BrowserSession] Upload failed for selector #{selector}: #{e.message}")
    false
  end

  def wait_for_selector(selector, timeout: 10_000)
    page.wait_for_selector(selector, timeout: timeout)
    true
  rescue Playwright::TimeoutError
    false
  end

  def wait_for_navigation(timeout: 15_000)
    page.wait_for_load_state("domcontentloaded", timeout: timeout)
  rescue Playwright::TimeoutError
    false
  end

  def current_url
    page.url
  end

  def page_text
    page.inner_text("body")
  rescue => e
    Rails.logger.warn("[BrowserSession] Could not get page text: #{e.message}")
    ""
  end

  def login_required?
    url = current_url.to_s.downcase
    return true if LOGIN_INDICATORS.any? { |indicator| url.include?(indicator) }

    text = page_text.downcase
    return true if text.include?("sign in to continue") || text.include?("log in to continue") || text.include?("please sign in")

    false
  end

  def captcha_detected?
    text = page_text.downcase
    CAPTCHA_INDICATORS.any? { |indicator| text.include?(indicator) }
  end

  def close
    @page&.close rescue nil
    @context&.close rescue nil
    @browser&.close rescue nil
    @playwright&.stop rescue nil
  end

  private

  def find_playwright_cli
    npx_path = `which npx`.strip
    return "npx" if npx_path.present? && File.exist?(npx_path)

    "npx"
  end

  def find_chrome_executable
    candidates = %w[
      /usr/bin/google-chrome-stable
      /usr/bin/google-chrome
      /usr/bin/chromium-browser
      /usr/bin/chromium
    ]
    candidates.find { |path| File.exist?(path) }
  end
end
