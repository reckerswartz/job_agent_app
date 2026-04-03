namespace :jobs do
  desc "Re-score all job listings for all users with profiles"
  task rescore: :environment do
    User.joins(:profiles).distinct.find_each do |user|
      count = JobListing.for_user(user).count
      next if count == 0

      puts "Re-scoring #{count} listings for #{user.email}..."
      JobRescoreJob.perform_later(user.id)
    end
    puts "Done. Jobs enqueued."
  end
end
