class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  discard_on ActiveJob::DeserializationError

  retry_on Timeout::Error, wait: 10.seconds, attempts: 2
  retry_on Net::OpenTimeout, wait: 10.seconds, attempts: 2
  retry_on Net::ReadTimeout, wait: 10.seconds, attempts: 2
end
