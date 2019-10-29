# == Schema Information
#
# Table name: tag_topics
#
#  id         :bigint           not null, primary key
#  topic      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TagTopic < ApplicationRecord
  validates :topic, presence: true

  has_many :taggings

  has_many :shortened_urls,
    through: :taggings,
    source: :shortened_url

  def popular_links
    links = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT
        *
      FROM
        taggings
      WHERE
        tag_topic_id = #{self.id}
    SQL

    return nil unless links.first.length > 0

    links.first
  end
end
