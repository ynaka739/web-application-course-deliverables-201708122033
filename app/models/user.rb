class User < ApplicationRecord
  include Search::UserSearch
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  has_many :microposts, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  has_many :favorites, dependent: :destroy
  has_many :favorite_microposts, through: :favorites, source: :micropost
  

  def follow(other_user)
    unless self == other_user
      # Relationship.find_or_create_by(follow_id: other_user.id, user_id: self.id)
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def like(micropost)
    # Favorite.find_or_create_by(micropost_id: micropost.id, user_id: self.id)
    self.favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  def dislike(micropost)
    # Favorite.find_by(micropost_id: micropost.id, user_id: self.id)
    favorite = favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  def favorite?(micropost)
    self.favorite_microposts.include?(micropost)
  end
  
  def feed_favorites
    Micropost.where(user_id: self.favorites_ids + [self.id])
  end
  
end