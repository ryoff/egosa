class SlackService
  WEBHOOK_URL = ENV['SLACK_API_WEBHOOK_URL']

  include ActiveModel::Model

  attr_reader :room_id

  define_model_callbacks :post

  before_post :valid?

  validates :room_id, presence: true

  def initialize(room_id)
    @room_id = room_id
  end

  def post(tweet, search_word)
    run_callbacks :post do
      slack_client.post text: "【検索ワード】#{search_word}", attachments: attachments(tweet)
    end
  end

  private

  def slack_client
    @slack_client ||= Slack::Notifier.new WEBHOOK_URL, channel: @room_id
  end

  def attachments(tweet)
    [
      {
        text: "#{tweet.full_text} \n\n *From* @#{tweet.user.screen_name} \n#{tweet.uri} \n",
        mrkdwn_in: [
          "text",
          "pretext"
        ]
      }
    ]
  end
end
