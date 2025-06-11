class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
    has_many :posts, class_name: "Post", foreign_key: "author_id"
    has_many :comments

    validates :nickname, presence: true, uniqueness: true

    paginates_per 50
end
