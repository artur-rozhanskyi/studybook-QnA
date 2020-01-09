require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-scheduler'

Sidekiq::Web.set :sessions, false
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  config.on(:startup) do
    SidekiqScheduler::Scheduler.instance.rufus_scheduler_options = { max_work_threads: 1 }
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
