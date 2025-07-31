require 'rails_helper'

RSpec.describe Post, type: :model do
    describe 'validators' do
        it { should validate_length_of(:title).is_at_least(5) }
        it { should validate_length_of(:title).is_at_most(50) }
        it { should validate_length_of(:body).is_at_least(15) }
        it { should validate_length_of(:body).is_at_most(1000) }
    end

    describe 'associations' do
        it { should belong_to(:user) }
        it { should have_many(:comments) }
    end
end
