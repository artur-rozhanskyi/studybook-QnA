class DailyDigestWorker < BaseWorker
  def perform
    User.find_each { |user| DailyMailer.digest(user).deliver }
  end
end
