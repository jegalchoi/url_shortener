# == Schema Information
#
# Table name: taggings
#
#  id               :bigint           not null, primary key
#  shortened_url_id :integer          not null
#  tag_topic_id     :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Tagging < ApplicationRecord
  validates :shortened_url_id, :tag_topic_id, presence: true

  belongs_to :shortened_url
  belongs_to :tag_topic
end
