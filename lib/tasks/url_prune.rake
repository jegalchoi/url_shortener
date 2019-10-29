namespace :url_prune do
  desc "Prune stale urls from shortened_urls table"
  task prune_url: :environment do
    minute = ENV['minute']
    puts "Pruning old urls..."
    ShortenedUrl.prune(minute)
  end
end