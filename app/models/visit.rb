# == Schema Information
#
# Table name: visits
#
#  id               :bigint           not null, primary key
#  user_id          :integer          not null
#  shortened_url_id :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#


class Visit < ApplicationRecord
  validates :user_id, :shortened_url_id, presence: true

  belongs_to :visitor,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  belongs_to :shortened_url,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :ShortenedUrl

  def Visit.record_visit!(user,shortened_url)
    visitor_id = user.id
    shortened_url_id = shortened_url.id
    Visit.create!(user_id: visitor_id, shortened_url_id: shortened_url_id)
  end
end
