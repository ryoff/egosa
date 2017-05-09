class ChatworkService
  CHATWORK_API_TOKEN = ENV['CHATWORK_API_TOKEN']

  include ActiveModel::Model

  attr_reader :room_id

  define_model_callbacks :post

  before_post :valid?

  validates :room_id, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999_999_999 }

  def initialize(room_id)
    @room_id = room_id
  end

  def post(tweet, search_word)
    run_callbacks :post do
      ChatWork.api_key = CHATWORK_API_TOKEN
      ChatWork::Message.create(room_id: @room_id, body: message(tweet, search_word))
    end
  end

  private

  def message(tweet, search_word)
    replace_not_allowed_words("[info][title]検索ワード【#{search_word}】[/title]#{tweet.full_text} [hr]@#{tweet.user.screen_name}\n#{tweet.uri.to_s} / #{tweet.created_at}[/info]")
  end

  def replace_not_allowed_words(text)
    # chatworkがunicodeに対応してないっぽいので、消す。
    text.encode('SJIS', 'UTF-8', invalid: :replace, undef: :replace, replace: '?').encode('UTF-8')
  end
end
