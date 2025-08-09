class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  has_many :likes, as: :likable, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user

  has_many :replies, class_name: "Comment", foreign_key: :replied_to_id
  belongs_to :replied_to, class_name: "Comment", optional: true, counter_cache: :replies_count

  validates :body, length: { minimum: 3, maximum: 200 }
  validate :replied_to_a_comment_on_the_same_post, if: :is_reply?
  validate :replied_to_not_a_reply, if: :is_reply?

  before_save :strip_body

  scope :not_replies, -> { where(replied_to: nil) }

  paginates_per 10

  def is_reply?
    replied_to_id.present?
  end

  private

  def replied_to_a_comment_on_the_same_post
    unless replied_to.post_id == post_id
      errors.add(:body, "replies to the comment from another post")
    end
  end

  def replied_to_not_a_reply
    if replied_to.replied_to
      errors.add(:body, "can't reply to a reply")
    end
  end

  def strip_body
    self.body = body.strip
  end
end
