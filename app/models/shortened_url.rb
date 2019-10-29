# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, :user_id, presence: true
  validate :no_spamming, :nonpremium_max

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    dependent: :destroy,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit

  has_many :visitors,
    Proc.new {distinct},
    through: :visits,
    source: :visitor
    
  has_many :taggings, dependent: :destroy

  has_many :tag_topics,
    through: :taggings,
    source: :tag_topic

  def self.random_code
    random = SecureRandom.urlsafe_base64
    random = SecureRandom.urlsafe_base64 until !ShortenedUrl.exists?(short_url: "#{random}")    
    random
  end

  def no_spamming
    num_submitted = submitter.submitted_urls.count { |url| Time.new - url.created_at < 60 }

    unless num_submitted < 5
      errors[:user_id] << "cannot create more than 5 URLs in under a minute...you already created #{num_submitted} in the last 60 seconds"
    end
  end

  def nonpremium_max
    num_submitted = submitter.submitted_urls.count

    unless num_submitted < 5 || submitter.premium == true
      errors[:user_id] << "non-premium users cannot create more than 5 total URLs...you already created #{num_submitted} URLs"
    end
  end

  def self.generate(submitter, url)
    user_id = submitter.id

    ShortenedUrl.create!(long_url: url, short_url: "#{ShortenedUrl.random_code}", user_id: user_id)
  end

  def self.prune(minute)
    seconds = minute * 60


    ShortenedUrl.all.each do |url|
      if url.visits.empty?
        url.destroy if (Time.now - url.created_at > seconds) && url.submitter.premium == false
      else
        url.destroy if (Time.now - url.visits.last.created_at > seconds) && url.submitter.premium == false
      end
    end

  end

  def num_clicks_test
    clicks = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT
        COUNT(*)
      FROM
        visits
      WHERE
        shortened_url_id = #{self.id}
    SQL
    
    return nil unless clicks.first.length > 0

    clicks.first.values.first
  end

  def num_clicks
    self.visits.count
  end

  def num_uniques_test
    uniques = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT
        COUNT (DISTINCT user_id)
      FROM
        visits
      WHERE
        shortened_url_id = #{self.id}
    SQL
    return nil unless uniques.first.length > 0

    uniques.first.values.first
  end
  
  def num_uniques
    self.visitors.count
  end

  def num_recent_uniques(time_period)
    uniques = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT
        COUNT (DISTINCT user_id)
      FROM
        visits
      WHERE
        shortened_url_id = #{self.id}
    SQL
    return nil unless uniques.first.length > 0

    uniques.first.values.first
  end

  
end
