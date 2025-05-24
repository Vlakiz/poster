class User < ApplicationRecord
    validates :login, presence: true, uniqueness: true
end
