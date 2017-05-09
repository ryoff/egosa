class ChatworkService
  CHATWORK_API_TOKEN   = ENV['CHATWORK_API_TOKEN']
  CHATWORK_DEV_ROOM_ID = ENV['CHATWORK_DEV_ROOM_ID']

  include ActiveModel::Model

  attr_reader :room_id

  define_model_callbacks :post

  before_post :valid?

  validates :room_id, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999_999_999 }

  def initialize(room_id)
    @room_id = Rails.env.production? ? room_id : CHATWORK_DEV_ROOM_ID
  end

  def post(tweet, search_word)
    run_callbacks :post do
      ChatWork.api_key = CHATWORK_API_TOKEN
      ChatWork::Message.create(room_id: @room_id, body: message(tweet, search_word))
    end
  end

  private

  def message(tweet, search_word)
    "[info][title]検索ワード【#{search_word}】[/title]#{tweet.full_text} [hr]@#{tweet.user.screen_name}\n#{tweet.uri.to_s} / #{tweet.created_at}[/info]"
  end
end
