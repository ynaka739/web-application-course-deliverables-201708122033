class Micropost < ApplicationRecord
  mount_uploader :image, ImageUploader
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 255 }
end