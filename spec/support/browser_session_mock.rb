RSpec.configure do |config|
  config.before(:each) do
    # Mock BrowserSession globally so no real browsers are launched in tests
    mock_session = instance_double(BrowserSession,
      navigate: "<html><body>mock page</body></html>",
      evaluate: [],
      snapshot: "<html></html>",
      click: true,
      type_text: true,
      screenshot: "/tmp/mock_screenshot.png",
      upload_file: true,
      wait_for_selector: true,
      wait_for_navigation: true,
      current_url: "https://example.com",
      page_text: "mock page text",
      login_required?: false,
      captcha_detected?: false,
      close: nil
    )
    allow(BrowserSession).to receive(:new).and_return(mock_session)
  end
end
