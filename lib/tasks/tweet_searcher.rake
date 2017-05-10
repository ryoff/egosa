namespace :tweet_searcher do
  desc "twitterから任意の検索ワードのtweetを検索し、chatサービスにポストする"
  task :run, ['word', 'chat_service', 'room_id', 'exclude_word'] => :environment do |task, args|
    # exclude_wordは | 区切り
    TweetSearcher.run(args)
  end
end
