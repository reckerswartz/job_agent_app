class ScanAllSourcesJob < ApplicationJob
  queue_as :scanning

  def perform
    JobSource.needs_scan.find_each do |source|
      criteria = source.user.job_search_criteria.default_criteria.first
      JobScanJob.perform_later(source.id, criteria&.id)
    end
  end
end
