class TweetSearcher
  class << self
    def run(args)
      tweet_searcher_args = TweetSearcher::Args.new(args)

      if tweet_searcher_args.valid?
        TweetSearcher::Search.new(tweet_searcher_args).run!
      else
        raise ArgumentError.new("rake taskの引数に誤りがあります。 #{tweet_searcher_args.errors.full_messages.join}")
      end
    end
  end

  class Search
    def initialize(tweet_searcher_args)
      @tweet_searcher_args = tweet_searcher_args
    end

    def run!
      twitter_client.search("#{@tweet_searcher_args.word} -rt #{@tweet_searcher_args.exclude_words_for_twitter_search_format}", twitter_search_options).take(20).reverse.collect do |tweet|
        # すでにdbにあればskip
        next if Tweet.find_by_word_and_since_id(@tweet_searcher_args.word, tweet.id)

        # 別tweetだけど、全く同じ本文なら、skip (非公式RTなど、大量に同じtweetでチャットが溢れる対策)
        # urlが含まれると、短縮urlが毎回ユニークになってしまうので、先頭〜20文字で比較している
        next if Tweet.has_duplicate_tweet?(@tweet_searcher_args.word, tweet.full_text[0,20])

        Tweet.new(
          since_id:    tweet.id,
          search_word: @tweet_searcher_args.word,
          name:        tweet.user.screen_name,
          full_text:   tweet.full_text,
          uri:         tweet.uri.to_s,
          tweet_time:  tweet.created_at
        ).save!

        # full_text内に除外ワードを含むtweetはポストしない
        next if @tweet_searcher_args.exclude_words.any? { |exclude_word| tweet.full_text.include?(exclude_word) }

        # 同様に、user.screen_nameに含まれる場合も除く
        next if @tweet_searcher_args.exclude_words.any? { |exclude_word| tweet.user.screen_name.include?(exclude_word) }

        # ユーザ名に @#{検索ワード} という文字列を含む場合は、検索ワードをつぶやいているのではなく、
        # 検索ワードをアカウント名に含むアカウントのつぶやきである可能性が高いので、
        # tweet自体は保存して、since_idは更新するが、chat_serviceにはポストしない
        #
        # 検索ワードは、 【hoge OR ほげ】や【hoge -ほげ】 など、様々なパターンが想定されるため
        # 決め打ちで最初の１ワードのみを対象とする
        first_search_word = @tweet_searcher_args.word.slice(/\A\w+/)
        next if tweet.user.screen_name.include?(first_search_word)

        # 同様に本文の最初が、 @***検索ワード** のようなパターンも除外する
        # 検索ワードがアカウント名に含まれるユーザに対する単なるRTである可能性が高い
        next if tweet.full_text.match?(/\A@\w*#{first_search_word}\w*/i)

        if chat_service.valid?
          chat_service.post(tweet, @tweet_searcher_args.word)
        else
          raise ArgumentError.new("#{@tweet_searcher_args.chat_service}へのポストに失敗しました。 #{chat_service.errors.full_messages.join}")
        end
      end
    end

    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end
    end

    def chat_service
      @chat_service ||= "#{@tweet_searcher_args.chat_service}_service".classify.constantize.new(@tweet_searcher_args.room_id)
    end

    def twitter_search_options
      { lang: 'ja', locale: 'ja', result_type: 'recent', since_id: Tweet.last_since_id(@tweet_searcher_args.word) }
    end
  end

  class Args
    include ActiveModel::Model

    attr_reader :word, :chat_service, :room_id, :exclude_words

    validates :word,         presence: true, length: { maximum: 50 }
    validates :chat_service, inclusion: { in: %w( slack chatwork ) }
    validates :room_id,      presence: true

    # args is
    #   #<Rake::TaskArguments word: word, chat_service: chat, room_id: room_id>
    def initialize(args)
      @word          = args[:word]
      @chat_service  = args[:chat_service]
      @room_id       = args[:room_id]
      @exclude_words = args[:exclude_word]&.split('|') || []
    end

    def exclude_words_for_twitter_search_format
      # "['hoge', 'fuga']
      # -> "-hoge -fuga"
      @exclude_words.map { |exclude_word| "-#{exclude_word}" }.join(' ')
    end
  end
end
