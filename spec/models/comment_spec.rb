require 'rails_helper'

RSpec.describe Comment, type: :model do
    describe 'validators' do
        it { should validate_presence_of(:body) }
    end

    describe 'associations' do
        it { should belong_to(:user) }
        it { should belong_to(:post) }
    end
end
