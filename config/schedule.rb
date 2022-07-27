set :environment, "development"
set :output, "/cronjob.txt"
every 1.minute do
    rake 'updater:update_counts'
end
