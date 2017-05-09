class Tweet < ApplicationRecord
  validates :search_word, presence: true, length: { maximum:  100 }
  validates :name,        presence: true, length: { maximum:  100 }
  validates :full_text,   presence: true, length: { maximum:  500 }
  validates :uri,         presence: true, length: { maximum: 1000 }

  class << self
    def last_since_id(word)
      where(search_word: word).last.try(:since_id) || 0
    end

    def find_by_word_and_since_id(word, since_id)
      where(search_word: word).find_by(since_id: since_id)
    end

    def has_duplicate_tweet?(word, full_text)
      where(search_word: word).where("tweets.full_text LIKE ?", "#{full_text}ruby%").size > 0
    end
  end
end
