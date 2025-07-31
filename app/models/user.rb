class User < ApplicationRecord
  MINIMUM_AGE = 14

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  has_many :posts, class_name: "Post", foreign_key: "author_id"
  has_many :comments
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :likable, source_type: "Post"
  has_many :liked_comments, through: :likes, source: :likable, source_type: "Comment"

  has_one_attached :avatar

  enum :role, [ :user, :moderator, :editor, :admin ]

  validates :nickname,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { minimum: 3, maximum: 30 },
    format: {
      with: /\A[A-z]\w+\z/,
      message: "should start with a letter and contain only letters, numbers or underscore (_)"
    }
  validates :first_name,
    presence: true,
    length: { minimum: 3, maximum: 30 },
    format: {
      with: /\A[A-z][A-z\s\-]+\z/,
      message: "can only contain letters, spaces, or hyphens"
    }
  validates :last_name,
    presence: true,
    length: { minimum: 3, maximum: 30 },
    format: {
      with: /\A[A-z][A-z\s\-]+\z/,
      message: "can only contain letters, spaces, or hyphens"
    }
  validates :date_of_birth, presence: true
  validates :signed_up_at, presence: true
  validates :country,
    presence: true,
    length: { is: 2 },
    inclusion: { in: ISO3166::Country.all.map(&:alpha2), message: "is not a valid country" }
  validates :visible, inclusion: [ true, false ]

  validate :must_be_at_least_14_years_old

  before_create :set_registration_date

  paginates_per 50

  private

  def must_be_at_least_14_years_old
    minimum_birth_date = MINIMUM_AGE.years.ago.to_date

    if date_of_birth > minimum_birth_date
      errors.add(:date_of_birth, "must be at least 14 years old")
    end
  end

  def set_registration_date
    self.signed_up_at = Time.now
  end
end
