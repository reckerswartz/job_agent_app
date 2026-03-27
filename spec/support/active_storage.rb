RSpec.configure do |config|
  config.after(:suite) do
    FileUtils.rm_rf(ActiveStorage::Blob.service.root) if ActiveStorage::Blob.service.respond_to?(:root)
  end
end

module ActiveStorageHelper
  def sample_resume_pdf
    fixture_file_upload("sample_resume.pdf", "application/pdf")
  end

  def sample_resume_txt
    fixture_file_upload("sample_resume.txt", "text/plain")
  end
end

RSpec.configure do |config|
  config.include ActiveStorageHelper
  config.include ActiveJob::TestHelper
end
