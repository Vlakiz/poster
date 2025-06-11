require 'rails_helper'

RSpec.describe Post, type: :model do
    describe 'validators' do
        it { should validate_presence_of :title }
        it { should validate_length_of(:title).is_at_least(5) }
        it { should validate_presence_of :body }
        it { should validate_length_of(:body).is_at_least(50) }
    end

    describe 'associations' do
        it { should belong_to(:user) }
        it { should have_many(:comments) }
    end
end
