namespace :tweet_searcher do
  desc "twitterから任意の検索ワードのtweetを検索し、chatサービスにポストする"
  task :run, ['word', 'chat_service', 'room_id'] => :environment do |task, args|
    TweetSearcher.run(args)
  end
end
