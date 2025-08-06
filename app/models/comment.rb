class Comment < ApplicationRecord
  scope :not_replies, -> { where(replied_to: nil) }

  belongs_to :user
  belongs_to :post, counter_cache: true

  has_many :likes, as: :likable, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user

  has_many :replies, class_name: "Comment", foreign_key: 'replied_to'
  belongs_to :replied_to, class_name: "Comment", optional: true

  validates :body, length: { minimum: 3, maximum: 200 }
  validate :replied_to_a_comment_on_the_same_post, if: :is_reply?

  paginates_per 5

  def is_reply?
    replied_to_id.present?
  end

  private

  def replied_to_a_comment_on_the_same_post
    unless replied_to.post_id == post_id
      errors.add(:body, "replies to the comment from another post")
    end
  end
end
