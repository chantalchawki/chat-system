set :environment, "development"
ENV.each { |k, v| env(k, v) }

set :output, "log/cron.log"

every 30.minute do
    puts 'Running CRONJOB'
    rake 'updater:update_counts'
end
